# frozen_string_literal: true

class Author < ApplicationRecord
  include AttachmentResizable

  has_one_attached :cover

  belongs_to :user

  validates :description, :name, presence: true

  def cover_large_url
    resize_attachment cover, '1920x1920'
  end

  def cover_thumbnail_url
    resize_attachment cover, '300x300'
  end
end
