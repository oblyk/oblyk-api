# frozen_string_literal: true

class GuideBookPdf < ApplicationRecord
  include ActivityFeedable
  include StripTagable

  has_one_attached :pdf_file
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  delegate :latitude, to: :crag
  delegate :longitude, to: :crag

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag
  delegate :feed_parent_object, to: :crag

  validates :name, :pdf_file, presence: true
  validates :pdf_file, blob: { content_type: ['application/pdf'] }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      description: description,
      author: author,
      publication_year: publication_year,
      pdf_file: Rails.application.routes.url_helpers.polymorphic_url(pdf_file, only_path: true),
      crag: {
        id: crag.id,
        name: crag.name,
        slug_name: crag.slug_name
      },
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
