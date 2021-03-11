# frozen_string_literal: true

module Geolocable
  extend ActiveSupport::Concern

  included do
    validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
    validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

    def self.geo_search(latitude, longitude, distance)
      __elasticsearch__.search(
        {
          query: {
            bool: {
              must: {
                match_all: {}
              },
              filter: {
                geo_distance: {
                  distance: distance,
                  location: {
                    lat: latitude.to_f,
                    lon: longitude.to_f
                  }
                }
              }
            }
          },
          sort: [
            {
              _geo_distance: {
                location: {
                  lat: latitude.to_f,
                  lon: longitude.to_f
                },
                order: 'asc',
                unit: 'km'
              }
            }
          ],
          from: 0,
          size: 500
        }
      )
    end

    def self.partner_geo_search(latitude, longitude, distance)
      __elasticsearch__.search(
        {
          query: {
            bool: {
              must: {
                match_all: {}
              },
              filter: {
                geo_distance: {
                  distance: distance,
                  partner_location: {
                    lat: latitude.to_f,
                    lon: longitude.to_f
                  }
                }
              }
            }
          },
          sort: [
            {
              _geo_distance: {
                partner_location: {
                  lat: latitude.to_f,
                  lon: longitude.to_f
                },
                order: 'asc',
                unit: 'km'
              }
            }
          ],
          from: 0,
          size: 500
        }
      )
    end
  end

  def location
    [latitude, longitude]
  end

  def partner_location
    [partner_latitude, partner_longitude]
  end

  def as_indexed_json(_options = {})
    if has_attribute?(:partner_latitude)
      as_json.merge(
        location: {
          lat: latitude.to_f,
          lon: longitude.to_f
        },
        partner_location: {
          lat: partner_latitude.to_f,
          lon: partner_longitude.to_f
        }
      )
    else
      as_json.merge(
        location: {
          lat: latitude.to_f,
          lon: longitude.to_f
        }
      )
    end
  end
end
