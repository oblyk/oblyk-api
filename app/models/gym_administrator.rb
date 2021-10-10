# frozen_string_literal: true

class GymAdministrator < ApplicationRecord
  belongs_to :user
  belongs_to :gym

  after_create :set_gym_is_administered

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      user_id: user_id,
      gym_id: gym_id,
      level: level,
      gym: {
        name: gym.name,
        id: gym.id
      },
      user: {
        name: user.full_name,
        slug_name: user&.slug_name,
        uuid: user.uuid,
        email: user.email
      }
    }
  end

  private

  def set_gym_is_administered
    gym.administered!
  end
end
