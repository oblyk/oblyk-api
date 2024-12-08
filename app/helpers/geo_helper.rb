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

  def self.deg2rad(degrees)
    Math::PI * degrees / 180.0
  end

  def self.rad2deg(radians)
    180.0 * radians / Math::PI
  end

  def self.wgs84_earth_radius(lat)
    # http://en.wikipedia.org/wiki/Earth_radius
    wgs84_a = 6_378_137.0
    wgs84_b = 6_356_752.3_142
    a_n = wgs84_a * wgs84_a * Math.cos(lat)
    b_n = wgs84_b * wgs84_b * Math.sin(lat)
    a_d = wgs84_a * Math.cos(lat)
    b_d = wgs84_b * Math.sin(lat)
    Math.sqrt((a_n * a_n + b_n * b_n) / (a_d * a_d + b_d * b_d))
  end

  def self.bounding_box(latitude_in_degrees, longitude_in_degrees, half_side_in_km)
    lat = GeoHelper.deg2rad latitude_in_degrees
    lon = GeoHelper.deg2rad longitude_in_degrees
    half_side = 1000 * half_side_in_km

    radius = GeoHelper.wgs84_earth_radius lat
    p_radius = radius * Math.cos(lat)

    lat_min = lat - half_side / radius
    lat_max = lat + half_side / radius
    lng_min = lon - half_side / p_radius
    lng_max = lon + half_side / p_radius

    {
      latitude_min: GeoHelper.rad2deg(lat_min),
      longitude_min: GeoHelper.rad2deg(lng_min),
      latitude_max: GeoHelper.rad2deg(lat_max),
      longitude_max: GeoHelper.rad2deg(lng_max)
    }
  end

  def self.point_central(coordinates)
    n = coordinates.length

    sum_lat = coordinates.map { |coord| coord[0] }.sum
    sum_long = coordinates.map { |coord| coord[1] }.sum

    # Calcul des moyennes
    avg_lat = sum_lat / n.to_f
    avg_long = sum_long / n.to_f

    [avg_lat, avg_long]
  end
end
