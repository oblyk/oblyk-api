# frozen_string_literal: true

class Author < ApplicationRecord
  has_one_attached :cover

  belongs_to :user

  validates :description, :name, presence: true

  def thumbnail_url
    Rails.application.routes.url_helpers.rails_representation_url(cover.variant(resize: '300x300').processed, only_path: true)
  end
end
