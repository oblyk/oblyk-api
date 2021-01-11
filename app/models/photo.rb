# frozen_string_literal: true

class Photo < ApplicationRecord
  has_one_attached :picture

  belongs_to :user, optional: true
  belongs_to :illustrable, polymorphic: true

  before_validation :init_posted_at

  validates :illustrable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :picture, blob: { content_type: :image }

  def thumbnail_url
    Rails.application.routes.url_helpers.rails_representation_url(picture.variant(resize: '300x300').processed, only_path: true)
  end

  private

  def init_posted_at
    self.posted_at ||= DateTime.current
  end
end
