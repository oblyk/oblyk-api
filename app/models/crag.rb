# frozen_string_literal: true

class Crag < ApplicationRecord
  include Searchable
  include Geolocable
  include SoftDeletable
  include Slugable
  include GapGradable
  include ParentFeedable
  include ActivityFeedable
  include RouteFigurable
  include Elevable

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
  ], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  belongs_to :department, optional: true
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
  has_many :rock_bars

  validates :name, :latitude, :longitude, :city, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true
  validate :validate_rocks

  after_update :update_routes_location
  after_save :historize_around_towns

  def location
    [latitude, longitude]
  end

  def rich_name
    "#{name} (#{city})"
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

  def all_photos_count
    sectors.sum(:photos_count) + crag_routes.sum(:photos_count) + (photos_count || 0)
  end

  def all_videos_count
    crag_routes.sum(:videos_count) + (videos_count || 0)
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

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_crag", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        rain: rain,
        sun: sun,
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        multi_pitch: multi_pitch,
        trad_climbing: trad_climbing,
        aid_climbing: aid_climbing,
        deep_water: deep_water,
        via_ferrata: via_ferrata,
        north: north,
        north_east: north_east,
        east: east,
        south_east: south_east,
        south: south,
        south_west: south_west,
        west: west,
        north_west: north_west,
        summer: summer,
        autumn: autumn,
        winter: winter,
        spring: spring,
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        code_country: code_country,
        country: country,
        city: city,
        region: region,
        rocks: rocks,
        photo: {
          id: photo&.id,
          url: photo ? photo.large_url : nil,
          cropped_url: photo ? photo.cropped_medium_url : nil,
          thumbnail_url: photo ? photo.thumbnail_url : nil
        },
        approaches: {
          min_time: min_approach_time,
          max_time: max_approach_time
        },
        routes_figures: {
          route_count: crag_routes_count,
          grade: {
            min_value: min_grade_value,
            max_value: max_grade_value,
            max_text: max_grade_text,
            min_text: min_grade_text
          }
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        comment_count: comments.count,
        link_count: links.count,
        follow_count: follows.count,
        park_count: parks.count,
        alert_count: alerts.count,
        video_count: videos.count,
        photo_count: photos.count,
        versions_count: versions.count,
        articles_count: articles_count,
        all_photos_count: all_photos_count,
        all_videos_count: all_videos_count,
        guide_books: {
          web_count: guide_book_webs.count,
          pdf_count: guide_book_pdfs.count,
          paper_count: guide_book_papers.count
        },
        creator: user&.summary_to_json,
        sectors: sectors.map { |sector| { id: sector.id, name: sector.name } },
        areas: areas.map { |area| { id: area.id, name: area.name, slug_name: area.slug_name } },
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def to_geo_json(minimalistic: false)
    Rails.cache.fetch("#{cache_key_with_version}/#{'minimalistic_' if minimalistic}geo_json_crag", expires_in: 28.days) do
      features = {
        type: 'Feature',
        properties: {
          type: 'Crag',
          id: id,
          name: name,
          icon: "crag-marker-#{climbing_key}"
        },
        geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
      }
      unless minimalistic
        features[:properties].merge!(
          {
            name: name,
            slug_name: slug_name,
            climbing_key: climbing_key,
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
          }
        )
      end
      features
    end
  end

  def historize_approach_times
    approaches_from_park = approaches.where(from_park: true)
    return if approaches_from_park.count.zero?

    min_time = nil
    max_time = nil
    approaches_from_park.find_each do |approach|
      next if approach.walking_time.blank?

      min_time = approach.walking_time if min_time.nil? || approach.walking_time < min_time
      max_time = approach.walking_time if max_time.nil? || approach.walking_time > max_time
    end
    update min_approach_time: min_time, max_approach_time: max_time
  end

  private

  def search_indexes
    [
      { value: name, column_names: %i[name] },
      { value: city, column_names: %i[city] }
    ]
  end

  def validate_rocks
    self.rocks ||= []
    return if rocks&.count&.zero?

    rocks.each do |rock|
      errors.add(:rocks, I18n.t('activerecord.errors.messages.inclusion')) if Rock::LIST.exclude? rock
    end
  end

  def update_routes_location
    return unless saved_change_to_latitude? || saved_change_to_longitude?

    crag_routes.each(&:set_location!)
  end

  def historize_around_towns
    HistorizeTownsAroundWorker.perform_in(1.hour, latitude, longitude, Time.current)
  end
end
