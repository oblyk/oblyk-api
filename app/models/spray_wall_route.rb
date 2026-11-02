# frozen_string_literal: true

class SprayWallRoute < ApplicationRecord
  belongs_to :spray_wall, counter_cache: :spray_wall_routes_count
  belongs_to :user
  has_one :gym, through: :spray_wall
  has_many :spray_wall_route_holds, dependent: :destroy
  has_many :spray_wall_holds, through: :spray_wall_route_holds

  validate :grade_validation

  before_validation :set_grade_value
  before_validation :historize_level_information
  before_save :historize_sub_level_max

  accepts_nested_attributes_for :spray_wall_route_holds, allow_destroy: true

  def spray_wall_route_holds_attributes=(attributes)
    super(sync_route_holds_attributes(attributes))
  end

  def app_path
    "/gyms/#{gym_id}/#{spray_wall.gym.slug_name}/spray-walls/#{spray_wall_id}/spray-wall-routes/#{id}"
  end

  def historize_level_information
    return unless level_index_changed?

    if level_index
      gym_level = gym.gym_levels.find_by(climbing_type: :spray_wall)
      level = gym_level.levels[level_index]
      self.level_length = gym_level.levels.count
      self.level_color = level["color"]
    else
      self.level_length = nil
      self.level_color = nil
    end
  end

  def historize_sub_level_max
    return unless sub_level_changed?
    return if sub_level.blank?

    gym_level = gym.gym_levels.find_by(climbing_type: :spray_wall)
    self.sub_level_max = gym_level.sub_level_max if gym_level.sub_level_enabled
  end

  private

  def set_grade_value
    self.grade_value = Grade.to_value(grade_text)
  end

  def grade_validation
    errors.add(:grade_text, I18n.t("activerecord.errors.messages.inclusion")) if grade_text.present? && !Grade.valid?(grade_text)
  end

  def sync_route_holds_attributes(attributes)
    incoming = attributes.respond_to?(:values) ? attributes.values : Array(attributes)
    incoming = incoming.map { |attrs| attrs.to_h.with_indifferent_access }

    # If there are duplicates in the payload, the last occurrence takes precedence
    incoming = incoming.index_by { |attrs| attrs[:spray_wall_hold_id].to_i }.values

    existing = spray_wall_route_holds.to_a.index_by(&:spray_wall_hold_id)

    # 1. Updates / new content
    upserts = incoming.map do |attrs|
      record = existing[attrs[:spray_wall_hold_id].to_i]
      record ? attrs.merge(id: record.id) : attrs.except(:id)
    end

    # 2. Removing what is no longer in the payload
    kept_ids = incoming.map { |attrs| attrs[:spray_wall_hold_id].to_i }
    removals = existing.reject { |hold_id, _| kept_ids.include?(hold_id) }
                       .values
                       .map { |record| { id: record.id, _destroy: true } }

    upserts + removals
  end
end
