# frozen_string_literal: true

class Approach < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  STYLES_LIST = %w[steep_descent soft_descent flat soft_ascent steep_ascent various].freeze

  before_save :init_path_metadata

  validates :polyline, presence: true
  validates :approach_type, inclusion: { in: STYLES_LIST }, allow_nil: true

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Approach',
        id: id,
        description: description,
        approach_type: approach_type,
        length: length,
        walking_time: walking_time,
        crag: {
          id: crag.id,
          name: crag.name,
          slug_name: crag.slug_name
        }
      },
      geometry: { type: 'LineString', "coordinates": revers_lat_lng }
    }
  end

  def walking_time
    return if path_metadata.blank?

    path_metadata.last['cumulative_time']
  end

  def elevations_form_api
    return unless polyline

    coordinates = []
    polyline.each do |point|
      coordinates << {
        latitude: point[0],
        longitude: point[1]
      }
    end

    GoogleMapElevationApi.elevations coordinates
  end

  def elevation_start
    return if path_metadata.blank?

    path_metadata.first['elevation']
  end

  def elevation_end
    return if path_metadata.blank?

    path_metadata.last['elevation']
  end

  def positive_drop
    drop_difference(:positive)
  end

  def negative_drop
    drop_difference(:negative)
  end

  def path_metadata!
    init_path_metadata(force: true)
    save
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      description: description,
      approach_type: approach_type,
      polyline: polyline,
      path_metadata: path_metadata,
      length: length,
      walking_time: walking_time,
      elevation: {
        start: elevation_start,
        end: elevation_end,
        positive_drop: positive_drop,
        negative_drop: negative_drop
      },
      crag: crag.summary_to_json,
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def drop_difference(type)
    return if path_metadata.blank?

    drop = 0

    path_metadata.each_with_index do |point, index|
      next if index.zero?

      previous_elevation = path_metadata[index - 1]['elevation']
      elevation = point['elevation']
      drop += elevation - previous_elevation if elevation > previous_elevation && type == :positive
      drop += elevation - previous_elevation if elevation < previous_elevation && type == :negative
    end
    drop
  end

  def init_path_metadata(force: false)
    return if !polyline_changed? && !force

    metadata = []
    elevations = elevations_form_api
    cumulative_distance = 0
    cumulative_time = 0
    developed_distance = 0

    return unless elevations

    elevations.each_with_index do |elevation, index|
      if index != 0
        location = elevation['location']
        previous_location = elevations[index - 1]['location']
        elevation_drop = elevation['elevation'] - elevations[index - 1]['elevation']
        distance_bwt = distance(
          [location['lat'], location['lng']],
          [previous_location['lat'], previous_location['lng']]
        )
        developed_distance_bwt = distance(
          [location['lat'], location['lng']],
          [previous_location['lat'], previous_location['lng']],
          elevation_drop
        )
        cumulative_distance += distance_bwt
        cumulative_time += time_by_length_and_degree(distance_bwt, developed_distance_bwt, elevation_drop).to_d
        developed_distance += developed_distance_bwt
      end
      metadata << {
        latitude: elevation['location']['lat'],
        longitude: elevation['location']['lng'],
        elevation: elevation['elevation'].round,
        cumulative_distance: cumulative_distance.round,
        cumulative_time: cumulative_time.round
      }
    end
    self.length = developed_distance
    self.path_metadata = metadata
  end

  def time_for_length(length, type)
    meter_by_hour = 4000
    meter_by_hour = 6000 if %w[steep_descent soft_descent].include?(type)
    meter_by_hour = 4000 if %w[flat soft_ascent various].include?(type)
    meter_by_hour = 2500 if %w[steep_ascent].include?(type)
    (length.to_d * 60.to_d / meter_by_hour.to_d)
  end

  def time_by_length_and_degree(length, developed_length, elevation)
    degree = Math.atan(elevation / length) * (180.0 / Math::PI)
    if degree <= 0
      (developed_length.to_d * 60.to_d / 4200.to_d)
    elsif degree <= 5
      (developed_length.to_d * 60.to_d / 4100.to_d)
    elsif degree <= 10
      (developed_length.to_d * 60.to_d / 4000.to_d)
    elsif degree <= 15
      (developed_length.to_d * 60.to_d / 3500.to_d)
    elsif degree <= 20
      (developed_length.to_d * 60.to_d / 1500.to_d)
    elsif degree >= 25
      (developed_length.to_d * 60.to_d / 600.to_d)
    end
  end

  def revers_lat_lng
    reverse_polyline = []
    polyline.each do |coordinates|
      reverse_polyline << [coordinates[1], coordinates[0]]
    end
    reverse_polyline
  end

  def distance(loc1, loc2, elevation = 0)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371 # Earth radius in kilometers
    rm = rkm * 1000 # Radius in meters

    dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map { |i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    meters = rm * c # Delta in meters
    if elevation.zero?
      meters
    else
      Math.sqrt(meters**2 + elevation.abs**2)
    end
  end
end
