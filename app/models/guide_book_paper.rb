# frozen_string_literal: true

class GuideBookPaper < ApplicationRecord
  include Searchable
  include Slugable
  include ActivityFeedable

  has_paper_trail only: %i[name author editor publication_year price_cents ean number_of_page weight]

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

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/guide_book_papers/summary.json',
        assigns: { guide_book_paper: self }
      )
    )
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[name],
            fuzziness: :auto
          }
        }
      }
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

  def feed_parent_id
    id
  end

  def feed_parent_type
    self.class.name
  end
end
