# frozen_string_literal: true

class GymGrade < ApplicationRecord
  belongs_to :gym

  DIFFICULTY_SYSTEM_LIST = %w[hold_color tag_color grade].freeze

  validates :name, presence: true
  validates :difficulty_system, inclusion: { in: DIFFICULTY_SYSTEM_LIST }
end
