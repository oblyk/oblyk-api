# frozen_string_literal: true

class GymSector < ApplicationRecord
  include SoftDeletable

  belongs_to :gym_space
  has_one :gym, through: :gym_space
  belongs_to :gym_grade
  has_many :gym_routes

  validates :name, :height, presence: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }

  default_scope { order(:group_sector_name, :name) }
end
