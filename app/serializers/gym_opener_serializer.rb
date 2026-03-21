# frozen_string_literal: true

class GymOpenerSerializer < BaseSerializer
  belongs_to :gym
  belongs_to :user

  attributes :id,
             :name,
             :first_name,
             :last_name,
             :slug_name,
             :deactivated_at,
             :gym_id

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
