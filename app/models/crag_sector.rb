# frozen_string_literal: true

class CragSector < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Slugable
  include GapGradable
  include RouteFigurable
  include Elevable
  include StripTagable
  include AttachmentResizable

  has_paper_trail only: %i[
    name
    description
    rain
    sun
    latitude
    longitude
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
  belongs_to :crag
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :alerts, as: :alertable
  has_many :photos, as: :illustrable
  has_many :crag_routes
  has_many :reports, as: :reportable
  has_many :rock_bars

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag
  delegate :feed_parent_object, to: :crag

  before_validation :historize_location

  after_update :update_routes_location!

  validates :name, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true

  def rich_name
    name
  end

  def to_geo_json(minimalistic: false)
    features = {
      type: 'Feature',
      properties: {
        type: 'CragSector',
        id: id,
        icon: 'sector-marker'
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
    unless minimalistic
      features[:properties].merge!(
        {
          name: name,
          description: description,
          slug_name: slug_name,
          map_thumbnail_url: photo.present? ? photo.thumbnail_url : nil,
          crag: {
            id: crag.id,
            name: crag.name,
            slug_name: crag.slug_name,
            map_thumbnail_url: crag.photo.present? ? crag.photo.thumbnail_url : nil
          }
        }
      )
    end
    features
  end

  def all_photos
    photos = self.photos
    crag_routes.each { |crag_route| photos += crag_route.photos }
    photos
  end

  def all_videos
    videos = []
    crag_routes.each { |crag_route| videos += crag_route.videos }
    videos
  end

  def set_location!
    historize_location
    save
  end

  def summary_to_json(with_crag: true)
    Rails.cache.fetch("#{cache_key_with_version}/summary_crag_sector#{'_without_crag' unless with_crag}", expires_in: 28.days) do
      json = {
        id: id,
        crag_id: crag_id,
        name: name,
        slug_name: slug_name,
        description: description,
        rain: rain,
        sun: sun,
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        north: north,
        north_east: north_east,
        east: east,
        south_east: south_east,
        south: south,
        south_west: south_west,
        west: west,
        north_west: north_west,
        routes_figures: {
          count: crag_routes_count,
          grade: {
            min_value: min_grade_value,
            max_value: max_grade_value,
            max_text: max_grade_text,
            min_text: min_grade_text
          }
        },
        photo: {
          id: photo&.id,
          url: photo ? photo.large_url : nil,
          cropped_url: photo ? photo.cropped_medium_url : nil, # TODO: must be deleted
          thumbnail_url: photo ? photo.thumbnail_url : nil, # TODO: must be deleted
          attachments: {
            picture: attachment_object(photo&.picture, 'CragSector_picture')
          }
        }
      }
      json[:crag] = crag.summary_to_json if with_crag
      json
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        versions_count: versions.count,
        photo_count: photos.count,
        creator: user&.summary_to_json(with_avatar: false),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def historize_location
    self.location = if latitude
                      [latitude, longitude]
                    else
                      [crag.latitude, crag.longitude]
                    end
  end

  def update_routes_location!
    return unless saved_change_to_latitude? || saved_change_to_longitude?

    crag_routes.each(&:set_location!)
  end
end
