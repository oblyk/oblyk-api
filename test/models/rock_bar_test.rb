# frozen_string_literal: true

require 'test_helper'

class RockBarTest < ActiveSupport::TestCase
  setup do
    @rock_bar = rock_bars(:rock_bar_one)
  end

  test 'rock bar is valid' do
    assert @rock_bar.valid?
  end

  test 'rock bar is invalid without polyline' do
    @rock_bar.polyline = nil
    assert @rock_bar.invalid?
  end

  test 'to_geo_json returns geojson format' do
    geo_json = @rock_bar.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'LineString', geo_json[:geometry][:type]
    assert_equal 'RockBar', geo_json[:properties][:type]
    assert_equal @rock_bar.id, geo_json[:properties][:id]
    assert_equal @rock_bar.crag_id, geo_json[:properties][:crag_id]
    assert_nil geo_json[:properties][:sector_id]
    assert_nil geo_json[:properties][:icon]

    # Vérifie l'inversion des coordonnées (lat/lng -> lng/lat pour GeoJSON)
    first_coord = @rock_bar.polyline.first
    assert_equal [first_coord[1], first_coord[0]], geo_json[:geometry][:coordinates].first
  end

  test 'summary_to_json returns correct keys' do
    summary = @rock_bar.summary_to_json
    assert_equal @rock_bar.id, summary[:id]
    assert_equal @rock_bar.polyline, summary[:polyline]
    assert_nil summary[:crag_sector_id]
    assert_equal @rock_bar.crag.id, summary[:crag][:id]
  end

  test 'detail_to_json returns correct keys' do
    detail = @rock_bar.detail_to_json
    assert_equal @rock_bar.id, detail[:id]
    assert_includes detail.keys, :crag
    assert_includes detail.keys, :history
    # Si crag_sector est présent
    @rock_bar.crag_sector = crag_sectors(:sector_one)
    detail_with_sector = @rock_bar.detail_to_json
    assert_includes detail_with_sector.keys, :crag_sector
  end
end
