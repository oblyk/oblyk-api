# frozen_string_literal: true

class Crag < ApplicationRecord
  include Searchable
  include Geolocable
  include SoftDeletable
  include Slugable
  include GapGradable
  include ParentFeedable
  include ActivityFeedable

  has_paper_trail only: %i[
    name
    rocks
    rain
    sun
    latitude
    longitude
    code_country
    country
    city
    region
    sport_climbing
    bouldering
    multi_pitch
    trad_climbing
    aid_climbing
    deep_water
    via_ferrata
    summer
    autumn
    winter
    spring
    north
    north_east
    east
    south_east
    south
    south_west
    west
    north_west
  ]

  mapping do
    indexes :location, type: 'geo_point'
  end

  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :follows, as: :followable
  has_many :alerts, as: :alertable
  has_many :videos, as: :viewable
  has_many :feeds, as: :feedable
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
  has_many :approaches
  has_many :article_crags
  has_many :articles, through: :article_crags

  validates :name, :latitude, :longitude, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true
  validate :validate_rocks

  after_update :update_routes_location

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/crags/summary.json',
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

  def rich_name
    "#{name} (#{city})"
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

  def update_climbing_type!
    climbing_types = crag_routes.select(:climbing_type).distinct&.pluck(:climbing_type)

    self.sport_climbing = climbing_types.include?('sport_climbing')
    self.bouldering = climbing_types.include?('bouldering')
    self.multi_pitch = climbing_types.include?('multi_pitch')
    self.trad_climbing = climbing_types.include?('trad_climbing')
    self.aid_climbing = climbing_types.include?('aid_climbing')
    self.deep_water = climbing_types.include?('deep_water')
    self.via_ferrata = climbing_types.include?('via_ferrata')

    save
  end

  def route_figures
    figures = {
      section_count: 0,
      route_count: 0,
      climbing_types: {
        sport_climbing: 0,
        bouldering: 0,
        multi_pitch: 0,
        trad_climbing: 0,
        aid_climbing: 0,
        deep_water: 0,
        via_ferrata: 0
      },
      degrees: {
        '1' => 0,
        '2' => 0,
        '3' => 0,
        '4' => 0,
        '5' => 0,
        '6' => 0,
        '7' => 0,
        '8' => 0,
        '9' => 0
      },
      levels: {
        '1a' => 0, '1b' => 0, '1c' => 0,
        '2a' => 0, '2b' => 0, '2c' => 0,
        '3a' => 0, '3b' => 0, '3c' => 0,
        '4a' => 0, '4b' => 0, '4c' => 0,
        '5a' => 0, '5b' => 0, '5c' => 0,
        '6a' => 0, '6b' => 0, '6c' => 0,
        '7a' => 0, '7b' => 0, '7c' => 0,
        '8a' => 0, '8b' => 0, '8c' => 0,
        '9a' => 0, '9b' => 0, '9c' => 0
      }
    }
    crag_routes.each do |crag_route|
      figures[:climbing_types][crag_route.climbing_type.to_sym] += 1
      figures[:route_count] += 1

      crag_route.sections.each do |section|
        next unless section['grade_value']

        figures[:section_count] += 1
        figures[:degrees][Grade.degree(section['grade_value'])] += 1
        figures[:levels][Grade.level(section['grade_value'])] += 1
      end
    end
    figures
  end

  private

  def validate_rocks
    return if rocks&.count&.zero?

    rocks.each do |rock|
      errors.add(:rocks, I18n.t('activerecord.errors.messages.inclusion')) if Rock::LIST.exclude? rock
    end
  end

  def update_routes_location
    return unless saved_change_to_latitude? || saved_change_to_longitude?

    crag_routes.each(&:set_location!)
  end
end
