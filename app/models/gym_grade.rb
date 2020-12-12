# frozen_string_literal: true

class GymGrade < ApplicationRecord
  belongs_to :gym
  has_many :gym_grade_lines, dependent: :destroy

  DIFFICULTY_SYSTEM_LIST = %w[hold_color tag_color grade].freeze

  validates :name, presence: true
  validates :difficulty_system, inclusion: { in: DIFFICULTY_SYSTEM_LIST }

  def next_grade_lines_order
    order = gym_grade_lines.last&.order || 0
    order + 1
  end
end
