# frozen_string_literal: true

class ContestWaveSerializer < BaseSerializer
  attributes :id,
             :name,
             :capacity,
             :contest_id

  attribute :contest_participants_count do |object|
    object.contest_participants.size
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
