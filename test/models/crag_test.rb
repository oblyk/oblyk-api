# frozen_string_literal: true

require 'test_helper'

class CragTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:rocher_des_aures)
  end

  test 'crag is valid' do
    assert @crag.valid?
  end

  test 'crag is invalid without name' do
    @crag.name = nil
    assert @crag.invalid?
    assert_includes @crag.errors[:name], 'is_mandatory'
  end

  test 'crag is invalid without latitude' do
    @crag.latitude = nil
    assert @crag.invalid?
  end

  test 'crag is invalid without longitude' do
    @crag.longitude = nil
    assert @crag.invalid?
  end

  test 'crag is invalid without city' do
    @crag.city = nil
    assert @crag.invalid?
  end

  test 'crag is invalid with wrong rain value' do
    @crag.rain = 'invalid_rain'
    assert @crag.invalid?
  end

  test 'crag is valid with correct rain value' do
    @crag.rain = Rain::LIST.first
    assert @crag.valid?
  end

  test 'crag is invalid with wrong sun value' do
    @crag.sun = 'invalid_sun'
    assert @crag.invalid?
  end

  test 'crag is valid with correct sun value' do
    @crag.sun = Sun::LIST.first
    assert @crag.valid?
  end

  test 'crag is invalid with wrong rock value' do
    @crag.rocks = ['invalid_rock']
    assert @crag.invalid?
  end

  test 'crag is valid with correct rock value' do
    @crag.rocks = [Rock::LIST.first]
    assert @crag.valid?
  end

  test 'crag is invalid with out of range latitude' do
    @crag.latitude = 91
    assert @crag.invalid?
    @crag.latitude = -91
    assert @crag.invalid?
  end

  test 'crag is invalid with out of range longitude' do
    @crag.longitude = 181
    assert @crag.invalid?
    @crag.longitude = -181
    assert @crag.invalid?
  end

  test 'location returns latitude and longitude' do
    assert_equal [@crag.latitude, @crag.longitude], @crag.location
  end

  test 'rich_name returns name and city' do
    assert_equal "#{@crag.name} (#{@crag.city})", @crag.rich_name
  end

  test 'app_path returns correct path' do
    assert_equal "/crags/#{@crag.id}/#{@crag.slug_name}", @crag.app_path
  end

  test 'climbing_key returns correct string' do
    @crag.sport_climbing = true
    @crag.multi_pitch = false
    @crag.trad_climbing = false
    @crag.aid_climbing = false
    @crag.bouldering = false
    @crag.deep_water = false
    @crag.via_ferrata = false
    assert_equal '10000', @crag.climbing_key

    @crag.bouldering = true
    assert_equal '10100', @crag.climbing_key

    @crag.sport_climbing = false
    @crag.multi_pitch = true
    @crag.bouldering = false
    assert_equal '01000', @crag.climbing_key

    @crag.multi_pitch = false
    @crag.trad_climbing = true
    assert_equal '01000', @crag.climbing_key

    @crag.trad_climbing = false
    @crag.aid_climbing = true
    assert_equal '01000', @crag.climbing_key

    @crag.aid_climbing = false
    @crag.deep_water = true
    assert_equal '00010', @crag.climbing_key

    @crag.deep_water = false
    @crag.via_ferrata = true
    assert_equal '00001', @crag.climbing_key
  end

  test 'all_photos_count returns sum of photos' do
    # Initial counts are 0
    assert_equal 0, @crag.all_photos_count

    @crag.photos_count = 5
    assert_equal 5, @crag.all_photos_count
  end

  test 'all_videos_count returns sum of videos' do
    # Initial counts are 0
    assert_equal 0, @crag.all_videos_count

    @crag.videos_count = 3
    assert_equal 3, @crag.all_videos_count
  end

  test 'summary_to_json returns correct keys' do
    summary = @crag.summary_to_json
    assert_equal @crag.id, summary[:id]
    assert_equal @crag.name, summary[:name]
    assert_nil summary[:slug_name] # Actually slug_name is nil in the fixture if not set
    assert_equal @crag.city, summary[:city]
    assert_includes summary.keys, :sport_climbing
    assert_includes summary.keys, :bouldering
  end

  test 'detail_to_json returns summary merged with more keys' do
    detail = @crag.detail_to_json
    assert_equal @crag.id, detail[:id]
    assert_includes detail.keys, :comment_count
    assert_includes detail.keys, :link_count
    assert_includes detail.keys, :all_photos_count
    assert_includes detail.keys, :all_videos_count
  end

  test 'to_geo_json returns geojson format' do
    geo_json = @crag.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'Point', geo_json[:geometry][:type]
    assert_equal [@crag.longitude.to_f, @crag.latitude.to_f, 0.0], geo_json[:geometry][:coordinates]
    assert_equal @crag.name, geo_json[:properties][:name]
  end

  test 'to_geo_json with minimalistic option' do
    geo_json = @crag.to_geo_json(minimalistic: true)
    assert_equal 'Feature', geo_json[:type]
    assert_nil geo_json[:properties][:sport_climbing]
  end

  test 'update_climbing_type! updates climbing types based on routes' do
    # Create a route for this crag
    route = CragRoute.new(
      name: 'Test Route',
      crag: @crag,
      climbing_type: 'sport_climbing',
      sections: [{ grade: '6a', grade_value: 10 }]
    )
    route.save!

    @crag.sport_climbing = false
    @crag.save!

    @crag.update_climbing_type!
    @crag.reload

    assert @crag.sport_climbing
    assert_not @crag.bouldering

    # Add a bouldering route
    CragRoute.create!(
      name: 'Test Bolt',
      crag: @crag,
      climbing_type: 'bouldering',
      sections: [{ grade: '7a', grade_value: 15 }]
    )

    @crag.update_climbing_type!
    @crag.reload
    assert @crag.sport_climbing
    assert @crag.bouldering
  end
end
