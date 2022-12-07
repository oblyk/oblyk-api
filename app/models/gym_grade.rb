# frozen_string_literal: true

class GymGrade < ApplicationRecord
  include SoftDeletable

  belongs_to :gym
  has_many :gym_grade_lines, dependent: :destroy
  has_many :gym_spaces
  has_many :gym_sectors

  POINT_SYSTEM_TYPE_LIST = %w[fix divisible none].freeze

  validates :name, presence: true
  validates :point_system_type, inclusion: { in: POINT_SYSTEM_TYPE_LIST }
  validate :validate_grading_system

  def next_grade_lines_order
    order = gym_grade_lines.last&.order || 0
    order + 1
  end

  def need_grade_line?
    difficulty_by_level?
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      difficulty_by_grade: difficulty_by_grade,
      difficulty_by_level: difficulty_by_level,
      tag_color: tag_color,
      hold_color: hold_color,
      point_system_type: point_system_type,
      next_grade_lines_order: next_grade_lines_order,
      need_grade_line: need_grade_line?,
      gym: {
        id: gym.id,
        slug_name: gym.slug_name,
        name: gym.name
      },
      grade_lines: gym_grade_lines.map(&:summary_to_json)
    }
  end

  def colors_system_mark
    gym_grade_lines.map { |gym_grade_line| gym_grade_line.colors.first }.join
  end

  private

  def validate_grading_system
    errors.add(:base, I18n.t('activerecord.errors.messages.difficulty_system')) if !difficulty_by_grade && !difficulty_by_level
    errors.add(:base, I18n.t('activerecord.errors.messages.identification_system')) if !difficulty_by_grade && !difficulty_by_level
  end
end
