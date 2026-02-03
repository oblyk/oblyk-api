# frozen_string_literal: true

class FfmeContestSerializer
  include JSONAPI::Serializer

  attributes :id,
             :contest_id,
             :status,
             :contest_type,
             :name,
             :description,
             :start_date,
             :end_date,
             :min_send_date,
             :max_send_date

  attribute :sendable, &:sendable?

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
