# frozen_string_literal: true

class AscentUserSerializer < BaseSerializer
  attributes :id

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  belongs_to :user
end
