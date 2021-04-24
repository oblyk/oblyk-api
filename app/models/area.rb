# frozen_string_literal: true

class Area < ApplicationRecord
  include Slugable
  include Searchable

  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  has_many :area_crags, dependent: :destroy
  has_many :crags, through: :area_crags
  has_many :crag_routes, through: :crags
  has_many :reports, as: :reportable
  has_many :links, as: :linkable

  validates :name, presence: true

  mapping do
    indexes :name, analyzer: 'french'
  end

  def crag_routes_count
    crags.sum(:crag_routes_count)
  end

  def hardest_route
    crags.order(max_grade_value: :desc).first
  end

  def easiest_route
    crags.where.not(min_grade_value: nil).order(min_grade_value: :asc).first
  end

  def all_photos
    photos = []
    crags.each do |crag|
      crag.crag_sectors.each { |crag_sector| photos += crag_sector.photos }
      crag.crag_routes.each { |crag_route| photos += crag_route.photos }
      photos += crag.photos
    end
    photos
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[name],
            fuzziness: 1
          }
        }
      }
    )
  end

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/areas/summary.json',
        assigns: { area: self }
      )
    )
  end
end
