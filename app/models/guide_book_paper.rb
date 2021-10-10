# frozen_string_literal: true

class GuideBookPaper < ApplicationRecord
  include Searchable
  include Slugable
  include ParentFeedable
  include ActivityFeedable
  include AttachmentResizable

  has_paper_trail only: %i[
    name
    author
    editor
    publication_year
    price_cents
    ean
    number_of_page
    weight
  ], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  has_one_attached :cover
  belongs_to :user, optional: true
  has_many :guide_book_paper_crags
  has_many :crags, through: :guide_book_paper_crags
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :reports, as: :reportable
  has_many :place_of_sales
  has_many :article_guide_book_papers
  has_many :articles, through: :article_guide_book_papers

  validates :name, presence: true
  validates :cover, blob: { content_type: :image }, allow_nil: true

  def cover_large_url
    resize_attachment cover, '700x700'
  end

  def cover_thumbnail_url
    resize_attachment cover, '300x300'
  end

  def all_photos_count
    photos_count = 0
    crags_ids = crags.pluck(:id)
    photos_count += Crag.where(id: crags_ids).sum(:photos_count)
    photos_count += CragSector.where(crag_id: crags_ids).sum(:photos_count)
    photos_count += CragRoute.where(crag_id: crags_ids).sum(:photos_count)
    photos_count
  end

  def all_photos
    photos = []
    crags.each { |crag| photos += crag.all_photos }
    photos
  end

  def summary_to_json
    {
      id: id,
      name: name,
      slug_name: slug_name,
      author: author,
      editor: editor,
      publication_year: publication_year,
      price_cents: price_cents,
      ean: ean,
      vc_reference: vc_reference,
      number_of_page: number_of_page,
      weight: weight,
      price: price_cents ? price_cents / 100 : nil,
      cover: cover.attached? ? cover_large_url : nil,
      thumbnail_url: cover.attached? ? cover_thumbnail_url : nil
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        photos_count: all_photos_count,
        crags_count: crags.count,
        links_count: links.count,
        versions_count: versions.count,
        articles_count: articles_count,
        crags: crags.map { |crag| { id: crag.id, name: crag.name } },
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
    )
  end

  private

  def search_indexes
    [{ value: name }]
  end
end
