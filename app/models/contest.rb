# frozen_string_literal: true

class Contest < ApplicationRecord
  include Slugable
  include AttachmentResizable
  include StripTagable
  include Archivable
  include SoftDeletable

  REGISTRATION_TOLERANCE = 20

  has_one_attached :banner
  belongs_to :gym

  has_many :contest_waves
  has_many :contest_categories
  has_many :contest_participants, through: :contest_categories
  has_many :contest_participant_ascents, through: :contest_participants
  has_many :contest_stages
  has_many :contest_stage_steps, through: :contest_stages
  has_many :contest_route_groups, through: :contest_stage_steps
  has_many :contest_routes, through: :contest_route_groups
  has_many :championship_contests
  has_many :championships, through: :championship_contests
  has_many :contest_teams

  before_validation :normalize_attributes
  before_create :set_draft_mode
  after_create :create_u_age

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :categorization_type, inclusion: { in: %w[official_under_age custom] }
  validates :combined_ranking_type, inclusion: { in: ContestService::Constant::COMBINED_RANKING_TYPE_LIST }, allow_nil: :nil
  validates :participant_per_team, numericality: { greater_than_or_equal_to: 2 }, if: proc { |record| record.team_contest }
  validates :name,
            :start_date,
            :end_date,
            :subscription_start_date,
            :subscription_end_date,
            :categorization_type,
            presence: true
  validate :validate_dates

  scope :upcoming, -> { where(draft: false, private: false).where('contests.end_date >= ?', Date.current) }

  def remaining_places
    total_capacity ? total_capacity - (contest_participants.count || 0) : nil
  end

  def one_day_event?
    start_date == end_date
  end

  def public_app_path
    "#{ENV['OBLYK_APP_URL']}/gyms/#{gym.id}/#{gym.slug_name}/contests/#{id}/#{slug_name}"
  end

  def subscription_opened?
    Date.current >= subscription_start_date && Date.current <= subscription_end_date
  end

  def authentification_opened?
    Date.current >= subscription_start_date && Date.current <= end_date
  end

  def finished?
    Date.current > end_date
  end

  def beginning_is_in_past?
    Date.current >= start_date
  end

  def ongoing?
    start_date <= Date.current && Date.current <= end_date
  end

  def coming?
    start_date >= Date.current
  end

  def summary_to_json
    data = Rails.cache.fetch("#{cache_key_with_version}/summary_contest", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        description: description,
        gym_id: gym_id,
        start_date: start_date,
        end_date: end_date,
        subscription_start_date: subscription_start_date,
        subscription_end_date: subscription_end_date,
        subscription_closed_at: subscription_closed_at,
        combined_ranking_type: combined_ranking_type,
        draft: draft,
        authorise_public_subscription: authorise_public_subscription,
        private: private,
        hide_results: hide_results,
        total_capacity: total_capacity,
        categorization_type: categorization_type,
        contest_participants_count: contest_participants.count,
        archived_at: archived_at,
        one_day_event: one_day_event?,
        team_contest: team_contest,
        participant_per_team: participant_per_team,
        optional_gender: optional_gender,
        attachments: {
          banner: attachment_object(banner)
        },
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        }
      }
    end
    data[:remaining_places] = remaining_places
    data[:finished] = finished?
    data[:ongoing] = ongoing?
    data[:coming] = coming?
    data[:beginning_is_in_past] = beginning_is_in_past?
    data[:subscription_opened] = subscription_opened?
    data[:authentification_opened] = authentification_opened?
    data
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: gym.summary_to_json,
        contest_categories: contest_categories.map(&:summary_to_json),
        contest_stages: contest_stages.map(&:summary_to_json),
        championships: championships.map(&:summary_to_json),
        contest_waves: contest_waves.map { |wave| { id: wave.id, name: wave.name, capacity: wave.capacity }},
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def banner_attachment_object
    attachment_object(banner)
  end

  def time_line
    times = {}
    # Open subscription event
    times[subscription_start_date.to_s] = {
      start_date: subscription_start_date,
      events: [
        {
          event_type: 'SubscriptionOpen',
          start_date: subscription_start_date,
          end_date: subscription_end_date
        }
      ]
    }

    # Open contest
    times[start_date.to_s] = {
      start_date: start_date,
      events: [
        {
          event_type: 'ContestStart',
          start_date: start_date
        }
      ]
    }

    # Steps
    groups = contest_route_groups.includes(
      :contest_time_blocks,
      contest_stage_step: :contest_stage,
      contest_route_group_categories: :contest_category
    )
    groups.find_each do |route_group|
      contest_stage = route_group.contest_stage_step.contest_stage
      contest_stage_step = route_group.contest_stage_step
      contest_categories = route_group.contest_route_group_categories.map(&:contest_category)

      stage = {
        id: contest_stage.id,
        climbing_type: contest_stage.climbing_type,
        name: contest_stage.name
      }
      stage_step = {
        id: contest_stage_step.id,
        name: contest_stage_step.name,
        step_order: contest_stage_step.step_order,
        self_reporting: contest_stage_step.self_reporting
      }
      categories = contest_categories.map do |category|
        {
          id: category.id,
          name: category.name,
          capacity: category.capacity,
          unisex: category.unisex,
          auto_distribute: category.auto_distribute
        }
      end
      if route_group.waveable
        route_group.contest_time_blocks.each do |contest_time_block|
          contest_wave = contest_time_block.contest_wave
          wave = {
            id: contest_wave.id,
            name: contest_wave.name
          }
          time_key = "#{contest_time_block.start_date}-#{contest_time_block.start_time.strftime('%H:%M')}"
          times[time_key] ||= {
            start_date: contest_time_block.start_date,
            start_time: contest_time_block.start_time,
            events: []
          }
          times[time_key][:events] << {
            event_type: 'ContestStep',
            end_date: contest_time_block.end_date,
            end_time: contest_time_block.end_time,
            additional_time: contest_time_block.additional_time,
            stage: stage,
            step: stage_step,
            categories: categories,
            genre_type: route_group.genre_type,
            wave: wave
          }
        end
      else
        time_key = "#{route_group.start_date}-#{route_group.start_time.strftime('%H:%M')}"
        times[time_key] ||= {
          start_date: route_group.start_date,
          start_time: route_group.start_time,
          events: []
        }
        times[time_key][:events] << {
          event_type: 'ContestStep',
          end_date: route_group.end_date,
          end_time: route_group.end_time,
          additional_time: route_group.additional_time,
          stage: stage,
          step: stage_step,
          categories: categories,
          genre_type: route_group.genre_type,
          wave: nil
        }
      end
    end

    # Contest end
    times["#{end_date}-23:59"] = {
      start_date: end_date,
      events: [
        {
          event_type: 'ContestEnd',
          end_date: end_date
        }
      ]
    }
    times = times.sort
    times.map(&:last)
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_contest")
    contest_categories.each(&:delete_summary_cache)
  end

  def delete_results_cache
    ContestService::Result.new(self).delete_cache_key
  end

  def results_to_csv(unisex: false, by_team: false)
    results = ContestService::Result.new(self, unisex: unisex, by_team: by_team, rich_data: true).results
    CSV.generate(headers: true, encoding: 'utf-8', col_sep: "\t") do |csv|
      header = []
      header << 'Classement général'
      header << 'Catégorie'
      header << 'Genre'
      header << 'Nom'
      header << 'Prénom'
      header << 'Date de naissance'
      header << 'Email'
      header << 'Affiliation'
      category_header = results[0]
      first_participant = category_header[:participants][0]
      first_participant[:stages].each do |stage|
        stage[:steps].each do |step|
          climbing_type = stage[:climbing_type] == 'bouldering' ? 'Bloc' : 'Voie'
          step_name = "#{climbing_type} - #{step[:name]}"
          header << "#{step_name} - Classement"
          header << "#{step_name} - Point"
        end
      end
      csv << header

      results.each do |category|
        category[:participants].each do |participant|
          participant_row = [
            participant[:global_rank],
            category[:category_name],
            category[:genre],
            participant[:last_name],
            participant[:first_name],
            participant[:date_of_birth],
            participant[:email],
            participant[:affiliation]
          ]
          participant[:stages].each do |stage|
            stage[:steps].each do |step|
              participant_row << step[:rank]
              participant_row << step[:points]&.round(5)
            end
          end
          csv << participant_row
        end
      end
    end
  end

  def destroy_contest
    transaction do
      championship_contests.each(&:destroy)
      destroy
    end
  end

  private

  def set_draft_mode
    self.draft = true
  end

  def normalize_attributes
    self.description = description&.strip
    self.description = nil if description.blank?

    self.total_capacity = nil if total_capacity.blank? || total_capacity.zero?
    self.combined_ranking_type ||= ContestService::Constant::COMBINED_RANKING_DECREMENT_POINTS
  end

  def create_u_age
    return unless categorization_type == 'official_under_age'

    obligations = ContestCategory::OBLIGATION_LIST.filter { |obligation| obligation != ContestCategory::BETWEEN_AGE }

    obligations.each do |obligation|
      contest_categories << ContestCategory.new(
        name: obligation.tr('_', ' ').titleize,
        capacity: total_capacity.present? ? total_capacity / obligations.size : nil,
        registration_obligation: obligation
      )
    end
  end

  def validate_dates
    errors.add(:subscription_end_date, 'before_start_date') if subscription_start_date && subscription_end_date < subscription_start_date
    errors.add(:subscription_end_date, 'before_end_date') if end_date < subscription_end_date
    errors.add(:end_date, 'before_start_date') if end_date < start_date
  end
end
