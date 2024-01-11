# frozen_string_literal: true

class GymSpace < ApplicationRecord
  include SoftDeletable
  include Publishable
  include Slugable
  include AttachmentResizable
  include StripTagable

  has_one_attached :banner
  has_one_attached :plan
  belongs_to :gym
  belongs_to :gym_grade
  belongs_to :gym_space_group, optional: true
  has_many :gym_sectors
  has_many :gym_routes, through: :gym_sectors

  default_scope { order(:order) }

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :plan, blob: { content_type: :image }, allow_nil: true

  after_create :delete_gym_cache
  after_save :remove_routes_cache
  after_destroy :delete_gym_cache

  def set_plan_dimension!
    return unless plan.attached?

    meta = ActiveStorage::Analyzer::ImageAnalyzer.new(plan.blob).metadata

    self.scheme_height = meta[:height]
    self.scheme_width = meta[:width]
    save
  end

  def plan_large_url
    resize_to_limit_attachment plan, [4000, 4000]
  end

  def plan_thumbnail_url
    resize_attachment plan, '500x500'
  end

  def plan_tiny_thumbnail_url
    resize_attachment plan, '100x100'
  end

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def summary_to_json(with_figures: false)
    data = Rails.cache.fetch("#{cache_key_with_version}/summary_gym_space", expires_in: 28.days) do
      {
        id: id,
        gym_grade_id: gym_grade_id,
        name: name,
        slug_name: slug_name,
        description: description,
        order: order,
        climbing_type: climbing_type,
        scheme_height: scheme_height,
        scheme_width: scheme_width,
        sectors_color: sectors_color,
        banner: banner.attached? ? banner_large_url : nil,
        plan: plan.attached? ? plan_large_url : nil,
        plan_thumbnail_url: plan.attached? ? plan_thumbnail_url : nil,
        plan_tiny_thumbnail_url: plan.attached? ? plan_tiny_thumbnail_url : nil,
        gym_space_group_id: gym_space_group_id,
        anchor: anchor,
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name,
          banner: gym.banner.attached? ? gym.banner_large_url : nil
        }
      }
    end
    if with_figures
      routes_figures = gym_routes.mounted.select('MAX(opened_at) AS max_opened_at, COUNT(*) AS routes_count').first
      data[:figures] = {
        routes_count: routes_figures[:routes_count],
        last_route_opened_at: routes_figures[:max_opened_at]
      }
    end
    data
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym_sectors: gym_sectors.map(&:summary_to_json),
        sorts_available: sorts_available,
        last_sector_order: gym_sectors.order(:order).last&.order
      }
    )
  end

  def destroy
    return if deleted?

    ActiveRecord::Base.transaction do
      gym_sectors.find_each(&:destroy)
      delete
    end
  end

  private

  def sorts_available
    sorts = GymGrade.select("SUM(difficulty_by_level) AS sortable_by_level, SUM(difficulty_by_grade) AS sortable_by_grade, SUM(IF(point_system_type != 'none', 1, 0)) AS sortable_by_point")
                    .joins(gym_sectors: :gym_routes)
                    .where(gym_sectors: { gym_space: self })
                    .where(gym_routes: { dismounted_at: nil })
    sorts = sorts.first
    {
      difficulty_by_level: sorts[:sortable_by_level]&.positive?,
      difficulty_by_grade: sorts[:sortable_by_grade]&.positive?,
      difficulty_by_point: sorts[:sortable_by_point]&.positive?
    }
  end

  def remove_routes_cache
    return unless saved_change_to_name?

    gym_routes.find_each do |gym_route|
      Rails.cache.delete("#{gym_route.cache_key_with_version}/summary_gym_route")
    end
  end

  def delete_gym_cache
    gym.delete_summary_cache
  end
end
