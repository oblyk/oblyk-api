# frozen_string_literal: true

class GymAdministrator < ApplicationRecord
  belongs_to :user
  belongs_to :gym

  validates :level, presence: true
end
