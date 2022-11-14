# frozen_string_literal: true

class GymGrade < ApplicationRecord
  include SoftDeletable

  belongs_to :gym
  has_many :gym_grade_lines, dependent: :destroy
  has_many :gym_spaces
  has_many :gym_sectors

  DIFFICULTY_SYSTEM_LIST = %w[hold_color tag_color grade pan].freeze

  validates :name, presence: true
  validates :difficulty_system, inclusion: { in: DIFFICULTY_SYSTEM_LIST }
  validate :validate_grading_system

  def next_grade_lines_order
    order = gym_grade_lines.last&.order || 0
    order + 1
  end

  def need_grade_line?
    difficulty_system != 'grade'
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      difficulty_system: difficulty_system,
      has_hold_color: has_hold_color,
      use_grade_system: use_grade_system,
      use_point_system: use_point_system,
      use_point_division_system: use_point_division_system,
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

  private

  def validate_grading_system
    errors.add(:base, I18n.t('activerecord.errors.messages.grade_system')) if !use_grade_system && !use_point_system && !use_point_division_system
    errors.add(:base, I18n.t('activerecord.errors.messages.one_point_system')) if use_point_system && use_point_division_system
  end
end
