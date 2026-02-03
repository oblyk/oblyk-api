# frozen_string_literal: true

class ContestWaveSerializer
  include JSONAPI::Serializer

  attributes :id,
             :name,
             :capacity,
             :contest_id

  attribute :contest_participants_count do |object|
    object.contest_participants.counts
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
