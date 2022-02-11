# frozen_string_literal: true

class Article < ApplicationRecord
  include Slugable
  include Publishable
  include ParentFeedable
  include ActivityFeedable
  include AttachmentResizable

  has_one_attached :cover

  belongs_to :author
  has_many :comments, as: :commentable
  has_many :article_crags
  has_many :crags, through: :article_crags
  has_many :article_guide_book_papers
  has_many :guide_book_papers, through: :article_guide_book_papers
  has_many :photos, as: :illustrable

  validates :name, :description, :body, :author, presence: true

  def view!
    self.views ||= 0
    self.views += 1
    save
  end

  def rich_name
    name
  end

  def location
    []
  end

  def cover_large_url
    resize_attachment cover, '1920x1920'
  end

  def cover_thumbnail_url
    resize_attachment cover, '300x300'
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_article") do
      {
        id: id,
        slug_name: slug_name,
        name: name,
        description: description,
        views: views,
        comments_count: comments_count,
        published_at: published_at,
        published: published?,
        cover_url: cover.attached? ? cover_large_url : nil,
        thumbnail_url: cover.attached? ? cover_thumbnail_url : nil
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        body: body,
        author_id: author_id,
        author: author.summary_to_json,
        crags: crags.map(&:summary_to_json),
        guide_book_papers: guide_book_papers.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end
end
