# frozen_string_literal: true

class Approach < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  STYLES_LIST = %w[steep_descent soft_descent flat soft_ascent steep_ascent various].freeze

  before_validation :set_length

  validates :polyline, :length, presence: true
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
    meter_by_hour = 4000
    meter_by_hour = 6000 if %w[steep_descent soft_descent].include?(approach_type)
    meter_by_hour = 4000 if %w[flat soft_ascent various].include?(approach_type)
    meter_by_hour = 2500 if %w[steep_ascent].include?(approach_type)
    (length.to_d * 60 / meter_by_hour).to_i
  end

  private

  def revers_lat_lng
    reverse_polyline = []
    polyline.each do |coordinates|
      reverse_polyline << [coordinates[1], coordinates[0]]
    end
    reverse_polyline
  end

  def set_length
    cumulate_distance = 0
    polyline.each_with_index do |coordinate, index|
      break if index >= polyline.count - 1

      cumulate_distance += distance(coordinate, polyline[index + 1])
    end
    self.length = cumulate_distance
  end

  def distance(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371 # Earth radius in kilometers
    rm = rkm * 1000 # Radius in meters

    dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map { |i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Delta in meters
  end
end
