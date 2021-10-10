# frozen_string_literal: true

class GymGradeLine < ApplicationRecord
  belongs_to :gym_grade
  has_one :gym, through: :gym_grade

  before_validation :init_grade_value

  validates :name, :colors, :order, presence: true
  validate :grading_value

  default_scope { order(:order) }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      colors: colors,
      order: order,
      grade_text: grade_text,
      grade_value: grade_value,
      points: points,
      gym_grade: {
        id: gym_grade.id,
        slug_name: gym_grade.name,
        difficulty_system: gym_grade.difficulty_system,
        use_grade_system: gym_grade.use_grade_system,
        use_point_system: gym_grade.use_point_system,
        use_point_division_system: gym_grade.use_point_division_system
      },
      gym: {
        id: gym.id,
        slug_name: gym.slug_name
      }
    }
  end

  private

  def init_grade_value
    self.grade_value = Grade.to_value grade_text if grade_text
  end

  def grading_value
    errors.add(:grade_text, I18n.t('activerecord.errors.messages.blank')) if gym_grade.use_grade_system && grade_text.blank?
    errors.add(:points, I18n.t('activerecord.errors.messages.blank')) if gym_grade.use_point_system && points.blank?
  end
end
