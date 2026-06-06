# frozen_string_literal: true

require 'test_helper'

class CragSectorTest < ActiveSupport::TestCase
  setup do
    @sector = crag_sectors(:sector_one)
    @crag = crags(:rocher_des_aures)
    @user = users(:normal_user)
  end

  test 'sector is valid' do
    assert @sector.valid?
  end

  test 'sector is invalid without name' do
    @sector.name = nil
    assert_not @sector.valid?
    assert_includes @sector.errors.keys, :name
  end

  test 'sector is invalid with wrong rain value' do
    @sector.rain = 'unknown'
    assert_not @sector.valid?
    assert_includes @sector.errors.keys, :rain
  end

  test 'sector is invalid with wrong sun value' do
    @sector.sun = 'unknown'
    assert_not @sector.valid?
    assert_includes @sector.errors.keys, :sun
  end

  test 'rich_name returns name' do
    assert_equal @sector.name, @sector.rich_name
  end

  test 'to_geo_json returns expected format' do
    geo_json = @sector.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'CragSector', geo_json[:properties][:type]
    assert_equal @sector.id, geo_json[:properties][:id]
    assert_equal 'Point', geo_json[:geometry][:type]
    assert_equal [@sector.longitude, @sector.latitude, 0.0], geo_json[:geometry][:coordinates]
  end

  test 'historize_location set location before validation' do
    sector = CragSector.new(
      name: 'New Sector',
      crag: @crag,
      latitude: 45.0,
      longitude: 5.0
    )
    assert_nil sector.location
    sector.valid?
    expected = [45.0, 5.0]
    if sector.location.first.is_a?(String)
      assert_equal expected.map(&:to_s), sector.location
    else
      assert_equal expected, sector.location
    end
  end

  test 'historize_location use crag location if sector latitude is nil' do
    sector = CragSector.new(
      name: 'New Sector',
      crag: @crag,
      latitude: nil
    )
    sector.valid?
    expected = [@crag.latitude, @crag.longitude]
    if sector.location.first.is_a?(String)
      assert_equal expected.map(&:to_s), sector.location
    else
      assert_equal expected, sector.location
    end
  end

  test 'summary_to_json returns expected keys' do
    json = @sector.summary_to_json
    assert_equal @sector.id, json[:id]
    assert_equal @sector.name, json[:name]
    assert_includes json.keys, :crag
    assert_includes json.keys, :routes_figures
  end

  test 'summary_to_json without crag' do
    json = @sector.summary_to_json(with_crag: false)
    assert_not_includes json.keys, :crag
  end

  test 'detail_to_json returns expected keys' do
    json = @sector.detail_to_json
    assert_includes json.keys, :versions_count
    assert_includes json.keys, :photo_count
    assert_includes json.keys, :creator
    assert_includes json.keys, :history
  end

  test 'update_routes_location! updates routes location' do
    sector = crag_sectors(:sector_one)
    route = CragRoute.new(
      name: 'Test Route',
      crag: sector.crag,
      crag_sector: sector,
      user: users(:normal_user),
      climbing_type: 'sport_climbing',
      height: 20,
      sections: [{ grade: '6a', climbing_type: 'sport_climbing' }]
    )
    route.save!

    sector.update!(latitude: 46.0, longitude: 6.0)

    route.reload
    assert_equal [46.0, 6.0].map(&:to_s), route.location if route.location.first.is_a?(String)
    assert_equal [46.0, 6.0], route.location if route.location.first.is_a?(Numeric)
  end
end
