# frozen_string_literal: true

class GymSpace < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Publishable
  include Slugable
  include AttachmentResizable
  include StripTagable

  attribute :banner_color, :string, default: '#ffffff'
  attribute :banner_bg_color, :string, default: '#f44336'
  attribute :banner_opacity, :integer, default: 1
  attribute :scheme_bg_color, :string, default: '#fafafa'

  has_one_attached :banner
  has_one_attached :plan
  belongs_to :gym
  belongs_to :gym_grade
  has_many :gym_sectors
  has_many :gym_routes, through: :gym_sectors

  default_scope { order(:order) }

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :plan, blob: { content_type: :image }, allow_nil: true

  def location
    [latitude, longitude]
  end

  def set_plan_dimension!
    return unless plan.attached?

    meta = ActiveStorage::Analyzer::ImageAnalyzer.new(plan.blob).metadata

    self.scheme_height = meta[:height]
    self.scheme_width = meta[:width]
    save
  end

  def plan_large_url
    resize_attachment plan, '4000x4000'
  end

  def plan_thumbnail_url
    resize_attachment plan, '500x500'
  end

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def summary_to_json
    {
      id: id,
      gym_grade_id: gym_grade_id,
      name: name,
      slug_name: slug_name,
      description: description,
      order: order,
      climbing_type: climbing_type,
      banner_color: banner_color,
      banner_bg_color: banner_bg_color,
      banner_opacity: banner_opacity,
      scheme_bg_color: scheme_bg_color,
      scheme_height: scheme_height,
      scheme_width: scheme_width,
      latitude: latitude,
      longitude: longitude,
      published_at: published_at,
      banner: banner.attached? ? banner_large_url : nil,
      plan: plan.attached? ? plan_large_url : nil
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name,
          banner: gym.banner.attached? ? gym.banner_large_url : nil,
          gym_sectors: gym_sectors.map(&:summary_to_json)
        }
      }
    )
  end
end
