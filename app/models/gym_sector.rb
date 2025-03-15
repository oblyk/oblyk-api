# frozen_string_literal: true

class GymSector < ApplicationRecord
  include SoftDeletable
  include StripTagable

  belongs_to :gym_space
  has_one :gym, through: :gym_space
  belongs_to :gym_grade, optional: true # TODO: DELETE AFTER MIGRATION
  has_many :gym_routes
  has_many :gym_route_covers, through: :gym_routes

  validates :name, :height, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  delegate :anchor, to: :gym_space

  after_save :remove_routes_cache

  default_scope { order(:order) }

  # TODO: DELETE AFTER MIGRATION
  def gym_grade
    GymGrade.unscoped { super }
  end

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
        three_d_path: three_d_path,
        three_d_height: three_d_height,
        three_d_elevated: three_d_elevated,
        gym_space_id: gym_space_id,
        can_be_more_than_one_pitch: can_be_more_than_one_pitch,
        min_anchor_number: min_anchor_number,
        max_anchor_number: max_anchor_number,
        anchor_ranges: anchor_ranges,
        anchor: anchor,
        have_three_d_path: three_d_path?,
        three_d_label_options: three_d_label_options,
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
    summary_to_json
  end

  def destroy
    return if deleted?

    ActiveRecord::Base.transaction do
      gym_routes.mounted.find_each(&:dismount!)
      delete
    end
  end

  def three_d_path?
    three_d_path.present?
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym_sector")
  end

  def anchor_ranges
    return [] if max_anchor_number.blank? || min_anchor_number.blank?

    if max_anchor_number >= min_anchor_number
      (min_anchor_number..max_anchor_number).to_a
    else
      (max_anchor_number..min_anchor_number).to_a
    end
  end

  private

  def remove_routes_cache
    return unless saved_change_to_name?

    gym_routes.find_each(&:delete_summary_cache)
  end
end
