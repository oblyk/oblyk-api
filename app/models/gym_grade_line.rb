# frozen_string_literal: true

class GymGradeLine < ApplicationRecord
  belongs_to :gym_grade

  before_validation :init_grade_value

  validates :name, :colors, :order, presence: true

  default_scope { order(:order) }

  private

  def init_grade_value
    self.grade_value = Grade.to_value grade_text
  end
end
