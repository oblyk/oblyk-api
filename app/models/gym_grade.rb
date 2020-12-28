# frozen_string_literal: true

class GymGrade < ApplicationRecord
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

  private

  def validate_grading_system
    errors.add(:base, I18n.t('activerecord.errors.messages.grade_system')) if !use_grade_system && !use_point_system
  end
end
