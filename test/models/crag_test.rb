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
end
