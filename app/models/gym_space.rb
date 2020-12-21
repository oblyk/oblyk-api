# frozen_string_literal: true

class GymSpace < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Publishable
  include Slugable

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

  before_validation :set_plan_dimension

  default_scope { order(:order) }

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :plan, blob: { content_type: :image }, allow_nil: true

  private

  def set_plan_dimension
    return unless plan.attached?

    meta = ActiveStorage::Analyzer::ImageAnalyzer.new(plan.blob).metadata

    self.scheme_height = meta[:height]
    self.scheme_width = meta[:width]
  end
end
