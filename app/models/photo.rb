# frozen_string_literal: true

class Photo < ApplicationRecord
  include ActivityFeedable

  has_one_attached :picture

  belongs_to :user, optional: true
  belongs_to :illustrable, polymorphic: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :feeds, as: :feedable

  before_validation :init_posted_at

  validates :illustrable_type, inclusion: { in: %w[Crag CragSector CragRoute].freeze }
  validates :picture, blob: { content_type: :image }

  delegate :longitude, to: :illustrable
  delegate :latitude, to: :illustrable
  delegate :feed_parent_id, to: :illustrable
  delegate :feed_parent_type, to: :illustrable
  delegate :feed_parent_object, to: :illustrable

  def thumbnail_url
    Rails.application.routes.url_helpers.rails_representation_url(picture.variant(resize: '300x300').processed, only_path: true)
  end

  def photo_height
    picture.blob.metadata['height']
  end

  def photo_width
    picture.blob.metadata['width']
  end

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/photos/summary.json',
        assigns: { photo: self }
      )
    )
  end

  private

  def init_posted_at
    self.posted_at ||= DateTime.current
  end
end
