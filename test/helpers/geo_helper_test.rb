# frozen_string_literal: true

require 'test_helper'

class GeoHelperTest < ActiveSupport::TestCase
  test 'geo_range returns 0 for same coordinates' do
    assert_equal 0, GeoHelper.geo_range(45.75, 4.85, 45.75, 4.85)
  end

  test 'geo_range returns correct distance between Lyon and Paris' do
    # Lyon : 45.75, 4.85
    # Paris : 48.85, 2.35
    # La distance est d'environ 392 km
    distance = GeoHelper.geo_range(45.75, 4.85, 48.85, 2.35)
    assert_in_delta 392, distance, 5
  end

  test 'deg2rad converts degrees to radians' do
    assert_in_delta Math::PI, GeoHelper.deg2rad(180), 0.0001
    assert_in_delta Math::PI / 2, GeoHelper.deg2rad(90), 0.0001
  end

  test 'rad2deg converts radians to degrees' do
    assert_in_delta 180, GeoHelper.rad2deg(Math::PI), 0.0001
    assert_in_delta 90, GeoHelper.rad2deg(Math::PI / 2), 0.0001
  end

  test 'wgs84_earth_radius returns radius for a given latitude' do
    # À l'équateur (lat 0), le rayon devrait être wgs84_a (6378137.0)
    assert_in_delta 6_378_137.0, GeoHelper.wgs84_earth_radius(0), 1
    # Aux pôles (lat PI/2), le rayon devrait être wgs84_b (6356752.3142)
    assert_in_delta 6_356_752.3142, GeoHelper.wgs84_earth_radius(Math::PI / 2), 1
  end

  test 'bounding_box returns correct coordinates' do
    # Lyon : 45.75, 4.85, 10km radius
    box = GeoHelper.bounding_box(45.75, 4.85, 10)

    assert box.key?(:latitude_min)
    assert box.key?(:longitude_min)
    assert box.key?(:latitude_max)
    assert box.key?(:longitude_max)

    assert box[:latitude_min] < 45.75
    assert box[:latitude_max] > 45.75
    assert box[:longitude_min] < 4.85
    assert box[:longitude_max] > 4.85
  end

  test 'point_central returns the average of coordinates' do
    coordinates = [
      [10, 20],
      [20, 40],
      [30, 60]
    ]
    # (10+20+30)/3 = 20
    # (20+40+60)/3 = 40
    assert_equal [20.0, 40.0], GeoHelper.point_central(coordinates)
  end
end
