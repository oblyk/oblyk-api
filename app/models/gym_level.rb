# frozen_string_literal: true

class GymLevel < ApplicationRecord
  belongs_to :gym

  HOLD_REPRESENTATION = 'hold'
  TAG_REPRESENTATION = 'tag'
  TAG_AND_HOLD_REPRESENTATION = 'hold_and_tag'
  LEVEL_REPRESENTATIONS = [HOLD_REPRESENTATION, TAG_REPRESENTATION, TAG_AND_HOLD_REPRESENTATION].freeze

  validates :climbing_type, :level_representation, presence: true
  validates :climbing_type, uniqueness: { scope: [:gym_id] }
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }
  validates :grade_system, inclusion: { in: Grade::GRADE_STYLES }, allow_blank: true
  validates :level_representation, inclusion: { in: LEVEL_REPRESENTATIONS }

  def summary_to_json
    {
      climbing_type: climbing_type,
      grade_system: grade_system,
      level_representation: level_representation,
      levels: levels, # { order color default_grade default_point }
      gym_id: gym_id
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        }
      })
  end

  def colors_system_mark
    levels.map { |level| level['color'] }.join
  end
end
