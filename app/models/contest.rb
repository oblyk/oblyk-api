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

  before_validation :normalize_attributes
  before_create :set_draft_mode
  after_create :create_u_age

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :categorization_type, inclusion: { in: %w[official_under_age custom] }
  validates :combined_ranking_type, inclusion: { in: ContestRanking::COMBINED_RANKING_TYPE_LIST }, allow_nil: :nil
  validates :name,
            :start_date,
            :end_date,
            :subscription_start_date,
            :subscription_end_date,
            :categorization_type,
            presence: true
  validate :validate_dates

  scope :upcoming, -> { where(draft: false, private: false).where('contests.end_date >= ?', Date.current) }

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def remaining_places
    total_capacity ? total_capacity - (contest_participants.count || 0) : nil
  end

  def one_day_event?
    start_date == end_date
  end

  def public_app_path
    "#{ENV['OBLYK_APP_URL']}/gyms/#{gym.id}/#{gym.slug_name}/contests/#{id}/#{slug_name}"
  end

  def results(category_id = nil, rich_data = false)
    rich_key = rich_data ? 'rich' : ''
    cache_key = category_id.present? ? "#{results_cache_key}-cat-#{category_id}-#{rich_key}" : "#{results_cache_key}-#{rich_key}"
    Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
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
            global_rank_point: nil,
            ranks: [],
            participant_id: participant.id,
            first_name: participant.first_name,
            last_name: participant.last_name,
            affiliation: participant.affiliation,
            stages: {}
          }
          if rich_data
            results[cat_key][:participants][participant_key][:email] ||= participant.email
            results[cat_key][:participants][participant_key][:date_of_birth] ||= participant.date_of_birth
          end
          stages.each do |stage|
            stage_key = "stage-#{stage.id}"
            results[cat_key][:participants][participant_key][:stages][stage_key] ||= {
              stage_id: stage.id,
              climbing_type: stage.climbing_type,
              stage_rank: nil,
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
        results[category_index][:participants].each_with_index do |participant, participant_index|
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
          number_of_participants = results[category_index][:participants].size

          # Get last rank of each step for first sort
          ranks = []
          participant[:stages].each_with_index do |stage, stage_index|
            last_step_rank = stage[:steps].map { |step| step[:rank] }.last
            rank_decimal = ''
            stage[:steps].map { |step| step[:rank] }
                         .reverse
                         .each_with_index do |rank, rank_index|
              next if rank_index.zero?

              rank_decimal = "#{rank_decimal}#{(rank || number_of_participants).to_s.rjust(number_of_participants.to_s.size, '0')}"
            end
            rank_decimal = "#{last_step_rank || number_of_participants}.#{rank_decimal}".to_f
            results[category_index][:participants][participant_index][:stages][stage_index][:stage_rank] = rank_decimal
            ranks << rank_decimal
          end

          # Calculate global rank points
          case combined_ranking_type
          when ContestRanking::COMBINED_RANKING_ADDITION
            rank_point = 0
            ranks.each do |rank|
              rank_point += rank || number_of_participants
            end
          when ContestRanking::COMBINED_RANKING_MULTIPLICATION
            rank_point = 1
            ranks.each do |rank|
              rank_point *= rank || number_of_participants
            end
          when ContestRanking::COMBINED_RANKING_DECREMENT_POINTS
            rank_point = 0
            ranks.each do |rank|
              rank_point += if rank.blank?
                              0
                            elsif rank <= 30
                              ContestRanking::COMBINED_RANKING_POINT_MATRIX[rank.to_i - 1].to_f
                            else
                              1.0 - (1.0 / (number_of_participants - 29)) * (rank - 29)
                            end
            end
          else
            rank_point = 0
            ranks.each do |rank|
              rank_point += rank || number_of_participants
            end
          end

          results[category_index][:participants][participant_index][:global_rank_point] = rank_point
        end

        # Sort participant by global rank point
        results[category_index][:participants] = if combined_ranking_type == ContestRanking::COMBINED_RANKING_DECREMENT_POINTS
                                                   results[category_index][:participants].sort_by { |participant| -participant[:global_rank_point] }
                                                 else
                                                   results[category_index][:participants].sort_by { |participant| participant[:global_rank_point] }
                                                 end

        # Create global rank index
        results[category_index][:participants].each_with_index do |participant, index|
          global_rank = if index.positive? && results[category_index][:participants][index - 1][:global_rank_point] == participant[:global_rank_point]
                          results[category_index][:participants][index - 1][:global_rank]
                        else
                          index + 1
                        end
          results[category_index][:participants][index][:global_rank] = global_rank
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
        combined_ranking_type: combined_ranking_type,
        draft: draft,
        authorise_public_subscription: authorise_public_subscription,
        private: private,
        total_capacity: total_capacity,
        categorization_type: categorization_type,
        contest_participants_count: contest_participants.count,
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
        contest_waves: contest_waves.map { |wave| { id: wave.id, name: wave.name }},
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
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

  def results_to_csv
    results = self.results nil, true
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
    self.combined_ranking_type ||= ContestRanking::COMBINED_RANKING_ADDITION
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
