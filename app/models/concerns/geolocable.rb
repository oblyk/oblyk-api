# frozen_string_literal: true

module Geolocable
  extend ActiveSupport::Concern

  included do
    validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
    validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

    def self.geo_search(latitude, longitude, distance)
      where(
        'ST_DISTANCE_SPHERE(POINT(longitude, latitude), POINT(:lng, :lat)) < :distance',
        lat: latitude.to_f,
        lng: longitude.to_f,
        distance: distance.to_i * 1000
      )
        .order(Arel.sql(sanitize_sql(['ST_DISTANCE_SPHERE(POINT(longitude, latitude), POINT(?, ?))', longitude.to_f, latitude.to_f])))
    end
  end
end
