# frozen_string_literal: true

class GuideBookPaperCrag < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  belongs_to :guide_book_paper

  validates :crag, uniqueness: { scope: :guide_book_paper }
end
