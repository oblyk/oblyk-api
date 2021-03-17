# frozen_string_literal: true

class GuideBookPdf < ApplicationRecord
  include ActivityFeedable

  has_one_attached :pdf_file
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag

  validates :name, :pdf_file, presence: true
  validates :pdf_file, blob: { content_type: ['application/pdf'] }
end
