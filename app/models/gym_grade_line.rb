# frozen_string_literal: true

class GymGradeLine < ApplicationRecord
  belongs_to :gym_grade
  has_one :gym, through: :gym_grade

  before_validation :init_grade_value

  validates :name, :colors, :order, presence: true
  validate :grading_value

  default_scope { order(:order) }

  private

  def init_grade_value
    self.grade_value = Grade.to_value grade_text if grade_text
  end

  def grading_value
    errors.add(:grade_text, I18n.t('activerecord.errors.messages.blank')) if gym_grade.use_grade_system && grade_text.blank?
    errors.add(:points, I18n.t('activerecord.errors.messages.blank')) if gym_grade.use_point_system && points.blank?
  end
end
