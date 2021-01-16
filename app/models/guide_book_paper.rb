# frozen_string_literal: true

class GuideBookPaper < ApplicationRecord
  include Searchable
  include Slugable

  has_one_attached :cover
  belongs_to :user, optional: true
  has_many :guide_book_paper_crags
  has_many :crags, through: :guide_book_paper_crags
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :reports, as: :reportable
  has_many :place_of_sales

  validates :name, presence: true
  validates :cover, blob: { content_type: :image }, allow_nil: true

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/guide_book_papers/search.json',
        assigns: { guide_book_paper: self }
      )
    )
  end

  def thumbnail_url
    Rails.application.routes.url_helpers.rails_representation_url(cover.variant(resize: '300x300').processed, only_path: true)
  end

  def all_photos
    photos = []
    crags.each { |crag| photos += crag.all_photos }
    photos
  end
end
