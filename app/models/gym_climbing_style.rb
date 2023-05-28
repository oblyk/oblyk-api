# frozen_string_literal: true

class GymClimbingStyle < ApplicationRecord
  include Deactivable

  belongs_to :gym
  has_many :gym_route_openers
  has_many :gym_routes, through: :gym_route_openers

  validates :style, :climbing_type, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }
  validates :style, inclusion: { in: ClimbingStyle::STYLE_LIST }

  def summary_to_json
    {
      id: id,
      style: style,
      climbing_type: climbing_type,
      color: color,
      gym_id: gym_id,
      deactivated_at: deactivated_at
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end
end
