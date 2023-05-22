# frozen_string_literal: true

class GymSpaceGroup < ApplicationRecord
  belongs_to :gym
  has_many :gym_spaces

  default_scope { order(:order) }

  validates :name, presence: true

  def summary_to_json
    {
      id: id,
      gym_id: gym_id,
      name: name,
      order: order,
      gym_space_ids: gym_spaces.pluck(:id),
      gym: {
        id: gym.id,
        name: gym.name,
        slug_name: gym.slug_name
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def destroy
    ActiveRecord::Base.transaction do
      gym_spaces.find_each do |gym_space|
        gym_space.gym_space_group = nil
        gym_space.save
      end
      delete
    end
  end
end
