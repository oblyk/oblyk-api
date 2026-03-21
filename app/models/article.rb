# frozen_string_literal: true

class Article < ApplicationRecord
  include Slugable
  include Publishable
  include AttachmentResizable

  has_one_attached :cover

  belongs_to :author
  has_many :comments, as: :commentable
  has_many :likes, as: :likeable
  has_many :article_crags
  has_many :crags, through: :article_crags
  has_many :article_guide_book_papers
  has_many :guide_book_papers, through: :article_guide_book_papers
  has_many :photos, as: :illustrable
  has_many :publications, as: :publishable

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

  def app_path
    "/articles/#{id}/#{slug_name}"
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_article", expires_in: 28.days) do
      {
        id: id,
        slug_name: slug_name,
        name: name,
        description: description,
        views: views,
        comments_count: comments_count,
        likes_count: likes_count,
        published_at: published_at,
        app_path: app_path,
        published: published?,
        attachments: {
          cover: attachment_object(cover)
        }
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

  def publication_push!
    return unless published?

    return if Publication.where(publishable_type: 'Article', publishable_id: id, publishable_subject: :create).exists?

    Publication.create(
      publishable_id: id,
      publishable_type: 'Article',
      publishable_subject: 'create',
      published_at: published_at,
      last_updated_at: published_at,
      generated: true,
      author_id: nil
    )
  end
end
