# frozen_string_literal: true

class ChampionshipCategory < ApplicationRecord
  include Slugable

  belongs_to :championship
  has_many :championship_category_matches, dependent: :destroy
  has_many :contest_categories, through: :championship_category_matches

  validates :name, presence: true

  def summary_to_json
    {
      id: id,
      name: name,
      slug_name: slug_name,
      championship_id: championship_id,
      championship: {
        id: championship.id,
        name: championship.name,
        slug_name: championship.slug_name
      },
      contest_categories: contest_categories.map(&:summary_to_json)
    }
  end
end
