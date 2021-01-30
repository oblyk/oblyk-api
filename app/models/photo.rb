# frozen_string_literal: true

class Photo < ApplicationRecord
  has_one_attached :picture

  belongs_to :user, optional: true
  belongs_to :illustrable, polymorphic: true
  has_many :reports, as: :reportable

  before_validation :init_posted_at
  before_validation :set_photo_dimension

  validates :illustrable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :picture, blob: { content_type: :image }

  def thumbnail_url
    Rails.application.routes.url_helpers.rails_representation_url(picture.variant(resize: '300x300').processed, only_path: true)
  end

  private

  def init_posted_at
    self.posted_at ||= DateTime.current
  end

  def set_photo_dimension
    return unless picture.attached?

    meta = ActiveStorage::Analyzer::ImageAnalyzer.new(picture.blob).metadata

    self.photo_height = meta[:height]
    self.photo_width = meta[:width]
  end
end
