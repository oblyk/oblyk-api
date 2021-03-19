# frozen_string_literal: true

class GuideBookPdf < ApplicationRecord
  include ActivityFeedable

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
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/guide_book_pdfs/summary.json',
        assigns: { guide_book_pdf: self }
      )
    )
  end
end
