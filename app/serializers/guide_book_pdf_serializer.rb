# frozen_string_literal: true

class GuideBookPdfSerializer
  include JSONAPI::Serializer

  belongs_to :user
  belongs_to :crag

  attributes :id,
             :name,
             :description,
             :author,
             :publication_year,
             :pdf_url

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
