# frozen_string_literal: true

module Geolocable
  extend ActiveSupport::Concern

  included do
    validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
    validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

    def self.geo_search(latitude, longitude, distance)
      where(
        'getRange(latitude, longitude, :lat, :lng) < :distance',
        lat: latitude.to_f,
        lng: longitude.to_f,
        distance: distance.to_i * 1000
      )
        .order("getRange(latitude, longitude, #{latitude.to_f} , #{longitude.to_f})")
    end

    def self.partner_geo_search(latitude, longitude, distance)
      where(
        'getRange(partner_latitude, partner_longitude, :lat, :lng) < :distance',
        lat: latitude.to_f,
        lng: longitude.to_f,
        distance: distance.to_i * 1000
      )
        .order("getRange(partner_latitude, partner_longitude, #{latitude.to_f} , #{longitude.to_f})")
    end
  end
end
