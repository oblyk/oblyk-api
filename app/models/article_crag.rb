# frozen_string_literal: true

class ArticleCrag < ApplicationRecord
  belongs_to :crag, counter_cache: :articles_count, touch: true
  belongs_to :article

  validates :article, uniqueness: { scope: :crag }
end
