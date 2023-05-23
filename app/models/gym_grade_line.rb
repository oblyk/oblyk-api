# frozen_string_literal: true

class GymGradeLine < ApplicationRecord
  belongs_to :gym_grade
  has_one :gym, through: :gym_grade

  before_validation :init_grade_value

  validates :name, :colors, :order, presence: true
  validate :grading_value

  default_scope { order(:order) }

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_grade_line", expires_in: 28.days) do
      detail_to_json
    end
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
        name: gym_grade.name,
        difficulty_by_grade: gym_grade.difficulty_by_grade,
        difficulty_by_level: gym_grade.difficulty_by_level,
        tag_color: gym_grade.tag_color,
        hold_color: gym_grade.hold_color,
        point_system_type: gym_grade.point_system_type
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
    errors.add(:grade_text, I18n.t('activerecord.errors.messages.blank')) if gym_grade.difficulty_by_grade? && grade_text.blank?
    errors.add(:points, I18n.t('activerecord.errors.messages.blank')) if gym_grade.point_system_type == 'fix' && points.blank?
  end
end
