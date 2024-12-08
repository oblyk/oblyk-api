# frozen_string_literal: true

class GymOpener < ApplicationRecord
  include Emailable
  include Slugable
  include Deactivable

  belongs_to :user, optional: true
  belongs_to :gym
  has_many :gym_route_openers
  has_many :gym_routes, through: :gym_route_openers

  validates :name, presence: true

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_opener", expires_in: 28.days) do
      data = {
        id: id,
        name: name,
        first_name: first_name,
        last_name: last_name,
        slug_name: slug_name,
        deactivated_at: deactivated_at,
        gym: gym.summary_to_json
      }
      data[:user] = user.summary_to_json if user
      data
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        email: email,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end
end
