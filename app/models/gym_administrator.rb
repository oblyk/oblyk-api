# frozen_string_literal: true

class GymAdministrator < ApplicationRecord
  belongs_to :user
  belongs_to :gym

  after_create :set_gym_is_administered

  private

  def set_gym_is_administered
    gym.administered!
  end
end
