# frozen_string_literal: true

class ArticleGuideBookPaper < ApplicationRecord
  belongs_to :guide_book_paper, counter_cache: :articles_count
  belongs_to :article

  validates :article, uniqueness: { scope: :guide_book_paper }
end
