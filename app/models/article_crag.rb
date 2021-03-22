# frozen_string_literal: true

class ArticleCrag < ApplicationRecord
  belongs_to :crag, counter_cache: :articles_count
  belongs_to :article

  validates :article, uniqueness: { scope: :crag }
end
