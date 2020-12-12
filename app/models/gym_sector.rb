# frozen_string_literal: true

class GymSector < ApplicationRecord
  include SoftDeletable

  belongs_to :gym_space
  belongs_to :gym_grade

  validates :name, :height, presence: true
  validates :climbing_type, inclusion: { in: Climb::LIST }
end
