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
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/articles/summary.json',
        assigns: { article: self }
      )
    )
  end
end
