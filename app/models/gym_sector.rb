# frozen_string_literal: true

class GymSector < ApplicationRecord
  include SoftDeletable
  include StripTagable

  belongs_to :gym_space
  has_one :gym, through: :gym_space
  belongs_to :gym_grade
  has_many :gym_routes

  validates :name, :height, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  default_scope { order(:name) }

  def summary_to_json
    {
      id: id,
      name: name,
      description: description,
      group_sector_name: group_sector_name,
      climbing_type: climbing_type,
      height: height,
      polygon: polygon,
      gym_space_id: gym_space_id,
      gym_grade_id: gym_grade_id,
      can_be_more_than_one_pitch: can_be_more_than_one_pitch,
      gym: {
        id: gym.id,
        slug_name: gym.slug_name
      },
      gym_space: {
        id: gym_space.id,
        slug_name: gym_space.slug_name
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym_route_count: gym_routes.count,
        gym_routes: gym_routes.map(&:summary_to_json)
      }
    )

  end
end
