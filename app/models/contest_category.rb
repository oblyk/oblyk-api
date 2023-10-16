# frozen_string_literal: true

class ContestCategory < ApplicationRecord
  U10 = 'u10'
  U12 = 'u12'
  U14 = 'u14'
  U16 = 'u16'
  U18 = 'u18'
  U20 = 'u20'
  SENIOR = 'senior'
  VETERAN_1 = 'veteran_1'
  VETERAN_2 = 'veteran_2'
  BETWEEN_AGE = 'between_age'

  OBLIGATION_LIST = [
    U10, U12, U14, U16, U18, U20, SENIOR, VETERAN_1, VETERAN_2, BETWEEN_AGE
  ].freeze

  UXX_LIST = [
    U10, U12, U14, U16, U18, U20, SENIOR, VETERAN_1, VETERAN_2
  ].freeze

  belongs_to :contest
  has_one :gym, through: :contest

  has_many :contest_participants
  has_many :contest_route_group_categories
  has_many :contest_route_groups, through: :contest_route_group_categories
  has_many :contest_stage_steps, through: :contest_route_groups
  has_many :contest_time_blocks, through: :contest_route_groups
  has_many :contest_waves, through: :contest_time_blocks

  before_validation :set_order
  before_validation :normalize_attributes
  after_save :delete_caches
  after_destroy :delete_caches

  validates :name, presence: true
  validates :registration_obligation, inclusion: { in: OBLIGATION_LIST }, allow_nil: true
  validate :age_limit_when_between_age

  default_scope { order(:order) }

  def under_age
    return nil if registration_obligation.blank? || registration_obligation == BETWEEN_AGE

    return 10 if registration_obligation == U10
    return 12 if registration_obligation == U12
    return 14 if registration_obligation == U14
    return 16 if registration_obligation == U16
    return 18 if registration_obligation == U18
    return 20 if registration_obligation == U20
    return 40 if registration_obligation == SENIOR
    return 50 if registration_obligation == VETERAN_1

    100 if registration_obligation == VETERAN_2
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_contest_category", expires_in: 28.days) do
      {
        id: id,
        name: name,
        description: description,
        slug_name: slug_name,
        order: order,
        capacity: capacity,
        unisex: unisex,
        registration_obligation: registration_obligation,
        min_age: min_age,
        max_age: max_age,
        under_age: under_age,
        auto_distribute: auto_distribute,
        waveable: waveable,
        contest_participants_count: contest_participants_count,
        contest_id: contest_id,
        waves: waves,
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        },
        contest: {
          id: contest.id,
          name: contest.name,
          slug_name: contest.slug_name
        }
      }
    end
  end

  def waves
    return [] unless waveable

    waves = []
    waves_count = contest.contest_waves.size
    contest.contest_waves.each do |wave|
      capacity_by_wave = capacity / waves_count
      participants_count = contest_participants.where(contest_wave_id: wave.id).count
      waves << {
        id: wave.id,
        name: wave.name,
        participants_count: participants_count,
        capacity: capacity_by_wave,
        remaining_places: capacity_by_wave - participants_count,
        time_blocks: wave.contest_time_blocks.order(:start_date, :start_time).map(&:summary_to_json)
      }
    end
    waves
  end

  def time_lines
    times = []
    contest_stage_steps.each do |step|
      stage ||= { stage_id: step.contest_stage.id, stage_name: step.contest_stage.name, steps: [] }
      route_groups = step.contest_route_groups.join(:contest_route_group_categories).where(contest_route_group_categories: { contest_category_id: id })
      times = []
      route_groups.each do |route_group|
        if route_group.waveable
          times.concat route_group.contest_time_blocks.map(&:summary_to_json)
        else
          times << {
            id: route_group.id,
            name: 'Mono vague',
            start_time: route_group.start_time,
            end_time: route_group.end_time
          }
        end
      end
      stage[:steps] << step
      times << stage
    end
    times
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: gym.summary_to_json,
        contest: contest.summary_to_json,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_contest_category")
  end

  private

  def delete_caches
    contest.contest_stage_steps.each(&:delete_summary_cache)
    contest_participants.each(&:delete_summary_cache)
  end

  def set_order
    return unless new_record?

    self.order ||= (contest.contest_categories.order(:order).last&.order || 0) + 1
  end

  def normalize_attributes
    self.description = nil if description.blank?
    self.capacity = nil if capacity&.zero?
    self.registration_obligation = nil if registration_obligation.blank?
  end

  def age_limit_when_between_age
    return unless registration_obligation == BETWEEN_AGE

    errors.add(:registration_obligation, 'doit avoir un age minimum ou maximum de renseigné') if min_age.blank? && max_age.blank?
  end
end
