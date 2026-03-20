# frozen_string_literal: true

class GuideBookWebSerializer < BaseSerializer
  belongs_to :user
  belongs_to :crag

  attributes :id,
             :name,
             :url,
             :publication_year

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
