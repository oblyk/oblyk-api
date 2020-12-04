# frozen_string_literal: true

class GuideBookPaper < ApplicationRecord
  has_one_attached :cover
  belongs_to :user, optional: true
  has_many :guide_book_paper_crags
  has_many :crags, through: :guide_book_paper_crags

  validates :name, presence: true
  validates :cover, blob: { content_type: :image }, allow_nil: true
end
