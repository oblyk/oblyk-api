# frozen_string_literal: true

class Word < ApplicationRecord
  include Slugable
  include Searchable

  has_one_attached :picture
  belongs_to :user, optional: true

  validates :name, :definition, presence: true

  default_scope { order(:name) }

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/words/search.json',
        assigns: { word: self }
      )
    )
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[name],
            fuzziness: :auto
          }
        }
      }
    )
  end
end
