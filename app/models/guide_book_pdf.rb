# frozen_string_literal: true

class GuideBookPdf < ApplicationRecord
  has_one_attached :pdf_file
  belongs_to :user, optional: true
  belongs_to :crag

  validates :name, :pdf_file, presence: true
  validates :pdf_file, blob: { content_type: ['application/pdf'] }
end
