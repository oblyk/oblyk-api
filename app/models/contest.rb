# frozen_string_literal: true

class Contest < ApplicationRecord
  include Slugable
  include AttachmentResizable
  include StripTagable
  include Archivable

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

  before_validation :normalize_attributes
  before_create :set_draft_mode
  after_create :create_u_age

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :categorization_type, inclusion: { in: %w[official_under_age custom] }
  validates :name,
            :start_date,
            :end_date,
            :subscription_start_date,
            :subscription_end_date,
            :categorization_type,
            presence: true
  validate :validate_dates

  scope :upcoming, -> { where(draft: false, private: false).where('contests.end_date >= ?', Date.current).where('contests.subscription_start_date <= ?', Date.current) }

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def remaining_places
    total_capacity ? total_capacity - (contest_participants_count || 0) : nil
  end

  def one_day_event?
    start_date == end_date
  end

  def public_app_path
    "#{ENV['OBLYK_APP_URL']}/gyms/#{gym.id}/#{gym.slug_name}/contests/#{id}/#{slug_name}"
  end

  def results(category_id = nil)
    cache_key = category_id.present? ? "#{results_cache_key}-cat-#{category_id}" : results_cache_key
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = {}
      points_by_steps = {}
      stage_steps = {}
      rankers = {}
      stages = contest_stages.includes(:contest_stage_steps).order(:stage_order)

      participant_by_steps = {}
      ContestParticipantStep.joins(contest_stage_step: :contest_stage)
                            .where(contest_stages: { contest_id: id })
                            .find_each do |participant_step|
        participant_by_steps[participant_step.contest_stage_step_id] ||= []
        participant_by_steps[participant_step.contest_stage_step_id] << participant_step.contest_participant_id
      end

      category_by_steps = {}
      ContestRouteGroupCategory.joins(contest_route_group: { contest_stage_step: :contest_stage })
                               .where(contest_stages: { contest_id: id })
                               .find_each do |group_category|
        category_by_steps[group_category.contest_route_group.contest_stage_step.id] ||= []
        category_by_steps[group_category.contest_route_group.contest_stage_step.id] << group_category.contest_category_id
      end

      # Filter by categories
      categories = category_id.present? ? contest_categories.where(id: category_id) : contest_categories

      categories.order(:order).each do |category|
        contest_participants.includes(:contest_participant_ascents)
                            .where(contest_category: category)
                            .find_each do |participant|
          cat_key = category.unisex ? "category-#{category.id}" : "category-#{category.id}-#{participant.genre}"
          results[cat_key] ||= {
            category_name: category.name,
            category_id: category.id,
            unisex: category.unisex,
            genre: participant.genre,
            order: category.order,
            participants: {}
          }

          participant_key = "participant-#{participant.id}"
          results[cat_key][:participants][participant_key] ||= {
            global_rank: nil,
            ranks: [],
            participant_id: participant.id,
            first_name: participant.first_name,
            last_name: participant.last_name,
            stages: {}
          }
          stages.each do |stage|
            stage_key = "stage-#{stage.id}"
            results[cat_key][:participants][participant_key][:stages][stage_key] ||= {
              stage_id: stage.id,
              climbing_type: stage.climbing_type,
              steps: []
            }
            stage_steps[stage.id] ||= stage.contest_stage_steps.order(:step_order)
            stage_steps[stage.id].each do |step|
              next unless category_by_steps[step.id]&.include? category.id

              rankers["#{cat_key}-#{step.id}"] ||= ContestRanking.new step, category, participant.genre
              scores = rankers["#{cat_key}-#{step.id}"].participant_scores(participant.id)
              results[cat_key][:participants][participant_key][:stages][stage_key][:steps] << {
                step_id: step.id,
                step_order: step.step_order,
                name: step.name,
                participant_for_next_step: step.default_participants_for_next_step,
                subscribe: participant_by_steps[step.id]&.include?(participant.id),
                rank: nil,
                index: nil,
                points: scores[:value],
                score_details: scores[:details],
                unit_details: scores[:units]
              }
              points_by_steps[cat_key] ||= {}
              points_by_steps[cat_key][stage_key] ||= {}
              points_by_steps[cat_key][stage_key]["step-#{step.id}"] ||= []
              points_by_steps[cat_key][stage_key]["step-#{step.id}"] << scores[:value] if scores[:value]
            end
          end
        end
      end

      # Sort points array
      points_by_steps.each do |cat_key, category|
        category.each do |stage_key, stage|
          stage.each do |step_key, _points|
            points_by_steps[cat_key][stage_key][step_key].sort!.reverse!
          end
        end
      end

      # Normalize results array and set step rank
      results = results.map(&:last)
      results.each_with_index do |category, category_index|
        results[category_index][:participants] = results[category_index][:participants].map(&:last)
        results[category_index][:participants].each_with_index do |_participant, participant_index|
          ranks = []
          results[category_index][:participants][participant_index][:stages] = results[category_index][:participants][participant_index][:stages].map(&:last)
          results[category_index][:participants][participant_index][:stages].each_with_index do |stage, stage_index|
            results[category_index][:participants][participant_index][:stages][stage_index][:steps].each_with_index do |step, step_index|
              cat_key = category[:unisex] ? "category-#{category[:category_id]}" : "category-#{category[:category_id]}-#{category[:genre]}"
              rank = points_by_steps[cat_key]["stage-#{stage[:stage_id]}"]["step-#{step[:step_id]}"].find_index(step[:points])
              rank += 1 if rank
              ranks.unshift rank
              results[category_index][:participants][participant_index][:stages][stage_index][:steps][step_index][:rank] = rank
            end
          end
          results[category_index][:participants][participant_index][:ranks] = ranks
        end
        number_of_participants = results[category_index][:participants].size
        results[category_index][:participants] = results[category_index][:participants].sort_by { |participant| participant[:ranks].map { |rank| rank || number_of_participants } }

        # Create global rank
        results[category_index][:participants].each_with_index do |_participant, index|
          results[category_index][:participants][index][:global_rank] = index + 1
        end
      end

      # Re index data for override rank when equality
      index_by_step = {}
      results.each_with_index do |category, category_index|
        results[category_index][:participants].each_with_index do |_participant, participant_index|
          results[category_index][:participants][participant_index][:stages].each_with_index do |stage, stage_index|
            results[category_index][:participants][participant_index][:stages][stage_index][:steps].each_with_index do |step, step_index|
              genre = category[:unisex] ? 'unisex' : category[:genre]
              key = "cat-#{category[:category_id]}-#{genre}-stage-#{stage[:stage_id]}-step-#{step[:step_id]}"
              index_by_step[key] ||= 0
              index_by_step[key] += 1
              results[category_index][:participants][participant_index][:stages][stage_index][:steps][step_index][:index] = index_by_step[key]
            end
          end
        end
      end
    end
  end

  def results_cache_key
    last_ascent = contest_participant_ascents.maximum(:registered_at) || 'no-ascents'
    "contest-results-#{id}-#{last_ascent}"
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
        subscription_opened: subscription_opened?,
        authentification_opened: authentification_opened?,
        finished: finished?,
        ongoing: ongoing?,
        coming: coming?,
        draft: draft,
        authorise_public_subscription: authorise_public_subscription,
        private: private,
        beginning_is_in_past: beginning_is_in_past?,
        total_capacity: total_capacity,
        categorization_type: categorization_type,
        contest_participants_count: contest_participants_count,
        archived_at: archived_at,
        banner: banner.attached? ? banner_large_url : nil,
        banner_thumbnail_url: banner.attached? ? banner_thumbnail_url : nil,
        one_day_event: one_day_event?,
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        }
      }
    end
    data[:remaining_places] = remaining_places
    data
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: gym.summary_to_json,
        contest_categories: contest_categories.map(&:summary_to_json),
        contest_stages: contest_stages.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def update_from_participant!
    self.contest_participants_count = contest_participants.count
    save
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
        climbing_type: contest_stage.climbing_type
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
    Rails.cache.delete(results_cache_key)
  end

  private

  def set_draft_mode
    self.draft = true
  end

  def normalize_attributes
    self.description = description&.strip
    self.description = nil if description.blank?

    self.total_capacity = nil if total_capacity.blank? || total_capacity.zero?
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
