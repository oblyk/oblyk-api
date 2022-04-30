# frozen_string_literal: true

module GeoHelper
  def self.geo_range(latitude_from, longitude_form, latitude_to, longitude_to)
    if latitude_from == latitude_to && longitude_form == longitude_to
      0
    else
      rad_latitude_from = Math::PI * latitude_from / 180
      rad_latitude_to = Math::PI * latitude_to / 180
      ta = longitude_form - longitude_to
      rad_ta = Math::PI * ta / 180
      dist = Math.sin(rad_latitude_from) * Math.sin(rad_latitude_to) + Math.cos(rad_latitude_from) * Math.cos(rad_latitude_to) * Math.cos(rad_ta)
      dist = 1 if dist > 1
      dist = Math.acos(dist)
      dist = dist * 180 / Math::PI
      dist = dist * 60 * 1.1515
      dist *= 1.609344

      dist.round
    end
  end
end
