# frozen_string_literal: true

require 'test_helper'

class ParkTest < ActiveSupport::TestCase
  setup do
    @park = parks(:park_one)
  end

  test 'park is valid' do
    assert @park.valid?
  end

  test 'park is invalid without latitude' do
    @park.latitude = nil
    assert @park.invalid?
  end

  test 'park is invalid without longitude' do
    @park.longitude = nil
    assert @park.invalid?
  end

  test 'park is invalid without crag' do
    @park.crag = nil
    assert @park.invalid?
  end

  test 'location returns latitude and longitude' do
    assert_equal [@park.latitude, @park.longitude], @park.location
  end

  test 'to_geo_json returns geojson format' do
    geo_json = @park.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'Point', geo_json[:geometry][:type]
    assert_equal [@park.longitude.to_f, @park.latitude.to_f, 0.0], geo_json[:geometry][:coordinates]
    assert_equal 'Park', geo_json[:properties][:type]
    assert_equal @park.id, geo_json[:properties][:id]
    assert_equal @park.crag_id, geo_json[:properties][:crag_id]
    assert_equal @park.description, geo_json[:properties][:description]
  end

  test 'to_geo_json with minimalistic option' do
    geo_json = @park.to_geo_json(minimalistic: true)
    assert_equal 'Feature', geo_json[:type]
    assert_nil geo_json[:properties][:description]
  end

  test 'summary_to_json returns correct keys' do
    summary = @park.summary_to_json
    assert_equal @park.id, summary[:id]
    assert_equal @park.description, summary[:description]
    assert_equal @park.latitude, summary[:latitude]
    assert_equal @park.longitude, summary[:longitude]
    assert_equal @park.elevation, summary[:elevation]
    assert_includes summary.keys, :attachments
  end

  test 'detail_to_json returns summary merged with more keys' do
    detail = @park.detail_to_json
    assert_equal @park.id, detail[:id]
    assert_includes detail.keys, :crag
    assert_includes detail.keys, :creator
    assert_includes detail.keys, :history
  end
end
