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

  has_one_attached :photo
  belongs_to :gym
  belongs_to :gym_grade
  has_many :gym_sectors
  has_many :gym_routes, through: :gym_sectors

  default_scope { order(:order) }

  validates :name, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }
end
