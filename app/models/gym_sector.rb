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

  after_save :remove_routes_cache

  default_scope { order(:order) }

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_sector", expires_in: 28.days) do
      {
        id: id,
        name: name,
        order: order,
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
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym_route_count: gym_routes.count,
        gym_routes: gym_routes.map(&:summary_to_json)
      }
    )
  end

  def destroy
    return if deleted?

    ActiveRecord::Base.transaction do
      gym_routes.mounted.find_each(&:dismount!)
      delete
    end
  end

  private

  def remove_routes_cache
    return unless saved_change_to_name?

    gym_routes.find_each(&:remove_cache!)
  end
end
