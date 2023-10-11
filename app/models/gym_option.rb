# frozen_string_literal: true

class GymOption < ApplicationRecord
  OPTION_CONTEST = 'contest'
  OPTION_PICTURE = 'picture'
  OPTION_STATISTIC = 'statistic'
  OPTION_PRINT_LABEL = 'print_label'
  OPTION_MULTI_GYM = 'multi_gym'
  OPTION_API = 'api'

  OPTION_LIST = [
    OPTION_CONTEST,
    OPTION_PICTURE,
    OPTION_STATISTIC,
    OPTION_PRINT_LABEL,
    OPTION_MULTI_GYM,
    OPTION_API
  ].freeze

  belongs_to :gym
  validates :option_type, inclusion: { in: OPTION_LIST }
  validates :start_date, presence: true

  after_save :delete_gym_cache

  def activated?
    start_date <= Date.current && (end_date.nil? || end_date >= Date.current)
  end

  def credited?
    return true unless option_type == OPTION_CONTEST

    unlimited_unit? || remaining_unit&.positive?
  end

  def usable?
    activated? && credited?
  end

  def summary_to_json
    {
      option_type: option_type,
      start_date: start_date,
      end_date: end_date,
      remaining_unit: remaining_unit,
      unlimited_unit: unlimited_unit,
      activated: activated?,
      credited: credited?,
      usable: usable?
    }
  end

  private

  def delete_gym_cache
    gym.delete_summary_cache
  end
end
