# frozen_string_literal: true

require 'test_helper'

class ApproachTest < ActiveSupport::TestCase
  setup do
    @approach = approaches(:approach_one)
  end

  test 'approach is valid' do
    assert @approach.valid?
  end

  test 'approach is invalid without polyline' do
    @approach.polyline = nil
    assert @approach.invalid?
  end

  test 'approach is invalid with wrong approach_type' do
    @approach.approach_type = 'invalid_type'
    assert @approach.invalid?
  end

  test 'approach is valid with correct approach_type' do
    @approach.approach_type = Approach::STYLES_LIST.first
    assert @approach.valid?
  end

  test 'app_path returns correct path' do
    assert_equal "/crags/#{@approach.crag.id}/#{@approach.crag.slug_name}/approaches/#{@approach.id}", @approach.app_path
  end

  test 'to_geo_json returns geojson format' do
    geo_json = @approach.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'LineString', geo_json[:geometry][:type]
    assert_equal 'Approach', geo_json[:properties][:type]
    assert_equal @approach.id, geo_json[:properties][:id]
    assert_equal @approach.crag_id, geo_json[:properties][:crag_id]
    assert_equal @approach.description, geo_json[:properties][:description]
    assert_equal @approach.approach_type, geo_json[:properties][:approach_type]
  end

  test 'to_geo_json with minimalistic option' do
    geo_json = @approach.to_geo_json(minimalistic: true)
    assert_equal 'Feature', geo_json[:type]
    assert_nil geo_json[:properties][:description]
  end

  test 'walking_time returns the last cumulative time from path_metadata' do
    @approach.path_metadata = [{ 'cumulative_time' => 5 }, { 'cumulative_time' => 12 }]
    assert_equal 12, @approach.walking_time
  end

  test 'elevation_start and elevation_end return correct values' do
    @approach.path_metadata = [{ 'elevation' => 700 }, { 'elevation' => 850 }]
    assert_equal 700, @approach.elevation_start
    assert_equal 850, @approach.elevation_end
  end

  test 'positive_drop and negative_drop return correct values' do
    @approach.path_metadata = [
      { 'elevation' => 700 },
      { 'elevation' => 750 },
      { 'elevation' => 730 },
      { 'elevation' => 800 }
    ]
    # Positive: (750-700) + (800-730) = 50 + 70 = 120
    # Negative: (730-750) = -20
    assert_equal 120, @approach.positive_drop
    assert_equal(-20, @approach.negative_drop)
  end

  test 'detail_to_json returns correct keys' do
    detail = @approach.detail_to_json
    assert_equal @approach.id, detail[:id]
    assert_equal @approach.app_path, detail[:app_path]
    assert_includes detail.keys, :polyline
    assert_includes detail.keys, :path_metadata
    assert_includes detail.keys, :elevation
    assert_includes detail.keys, :crag
    assert_includes detail.keys, :creator
  end
end
