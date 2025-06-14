# frozen_string_literal: true

class ContestCategory < ApplicationRecord
  include StripTagable

  U6 = 'u6'
  U8 = 'u8'
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
    U6, U8, U10, U12, U14, U16, U18, U20, SENIOR, VETERAN_1, VETERAN_2, BETWEEN_AGE
  ].freeze

  UXX_LIST = [
    U6, U8, U10, U12, U14, U16, U18, U20, SENIOR, VETERAN_1, VETERAN_2
  ].freeze

  UNDER_AGE_BY_UXX = {
    U6 => 6,
    U8 => 8,
    U10 => 10,
    U12 => 12,
    U14 => 14,
    U16 => 16,
    U18 => 18,
    U20 => 20,
    SENIOR => 40,
    VETERAN_1 => 50,
    VETERAN_2 => 100
  }.freeze

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
  validate :validate_capacity, if: proc { |record| record.parity }

  default_scope { order(:order) }

  def under_age
    return nil if registration_obligation.blank? || registration_obligation == BETWEEN_AGE

    UNDER_AGE_BY_UXX[registration_obligation]
  end

  def over_age
    return min_age if min_age.present?
    return nil unless UXX_LIST.include?(registration_obligation)

    uxx_list = contest.contest_categories.where(registration_obligation: UXX_LIST).pluck(:registration_obligation).uniq
    uxx_list.sort! { |a, b| UNDER_AGE_BY_UXX[a] - UNDER_AGE_BY_UXX[b] }
    registration_index = uxx_list.find_index(registration_obligation)
    registration_index.zero? ? 0 : UNDER_AGE_BY_UXX[uxx_list[registration_index - 1]]
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
        over_age: over_age,
        auto_distribute: auto_distribute,
        waveable: waveable,
        contest_participants_count: contest_participants.count,
        contest_participants_female_count: contest_participants.where(genre: :female).count,
        contest_participants_male_count: contest_participants.where(genre: :male).count,
        contest_id: contest_id,
        waves: waves,
        parity: parity,
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
    contest.contest_waves.each do |wave|
      participants_count = contest.contest_participants.where(contest_wave_id: wave.id).count
      wave_capacity = wave.capacity || capacity || contest.total_capacity
      remaining_places = wave_capacity ? wave_capacity - participants_count : nil
      waves << {
        id: wave.id,
        name: wave.name,
        participants_count: participants_count,
        capacity: wave_capacity,
        remaining_places: remaining_places,
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
    contest.delete_results_cache
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

    errors.add(:registration_obligation, 'must_have_a_minimum_or_maximum_age_specified') if min_age.blank? && max_age.blank?
  end

  def validate_capacity
    errors.add(:capacity, 'must_be_specified') if capacity.blank?
    errors.add(:capacity, 'cannot_be_odd') if capacity.present? && !capacity&.even?
  end
end
