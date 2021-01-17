# frozen_string_literal: true

class Crag < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable

  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :alerts, as: :alertable
  has_many :videos, as: :viewable
  has_many :parks
  has_many :crag_sectors
  alias_attribute :sectors, :crag_sectors
  has_many :crag_routes
  has_many :area_crags
  has_many :areas, through: :area_crags
  has_many :guide_book_webs
  has_many :guide_book_pdfs
  has_many :guide_book_paper_crags
  has_many :guide_book_papers, through: :guide_book_paper_crags
  has_many :photos, as: :illustrable
  has_many :reports, as: :reportable

  validates :name, :latitude, :longitude, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true
  validate :validate_rocks

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/crags/search.json',
        assigns: { crag: self }
      )
    )
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[name city],
            fuzziness: :auto
          }
        }
      }
    )
  end

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Crag',
        id: id,
        name: name,
        slug_name: slug_name,
        climbing_key: climbing_key,
        icon: "crag-marker-#{climbing_key}",
        localization: "#{city}, #{region}",
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        multi_pitch: multi_pitch,
        trad_climbing: trad_climbing,
        aid_climbing: aid_climbing,
        deep_water: deep_water,
        via_ferrata: via_ferrata,
        map_thumbnail_url: photo.present? ? photo.thumbnail_url : nil,
        route_count: crag_routes_count,
        grade_min_value: min_grade_value,
        grade_max_value: max_grade_value,
        grade_max_text: max_grade_text,
        grade_min_text: min_grade_text
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
  end

  def climbing_key
    key = ''
    key += sport_climbing ? '1' : '0'
    key += multi_pitch || trad_climbing || aid_climbing ? '1' : '0'
    key += bouldering ? '1' : '0'
    key += deep_water ? '1' : '0'
    key += via_ferrata ? '1' : '0'
    key
  end

  def all_photos
    photos = self.photos
    crag_sectors.each { |crag_sector| photos += crag_sector.photos }
    crag_routes.each { |crag_route| photos += crag_route.photos }
    photos
  end

  def all_videos
    videos = self.videos
    crag_routes.each { |crag_route| videos += crag_route.videos }
    videos
  end

  private

  def validate_rocks
    return if rocks&.count&.zero?

    rocks.each do |rock|
      errors.add(:rocks, I18n.t('activerecord.errors.messages.inclusion')) if Rock::LIST.exclude? rock
    end
  end
end
