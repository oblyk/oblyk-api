# frozen_string_literal: true

require 'test_helper'

class CragRouteTest < ActiveSupport::TestCase
  setup do
    @route_one = crag_routes(:route_one)
    @route_two = crag_routes(:route_two)
    @multi_pitch = crag_routes(:multi_pitch_route)
  end

  test 'crag_route is valid' do
    assert @route_one.valid?
  end

  test 'crag_route is invalid without name' do
    @route_one.name = nil
    assert @route_one.invalid?
  end

  test 'crag_route is invalid without climbing_type' do
    @route_one.climbing_type = nil
    assert @route_one.invalid?
  end

  test 'crag_route is invalid with wrong climbing_type' do
    @route_one.climbing_type = 'invalid_type'
    assert @route_one.invalid?
  end

  test 'crag_route is invalid with negative height' do
    @route_one.height = -1
    assert @route_one.invalid?
  end

  test 'rich_name returns grade and name' do
    assert_equal '6a - Route One', @route_one.rich_name
  end

  test 'grade_to_s returns pitch count for multi_pitch' do
    assert_equal '2L.', @multi_pitch.grade_to_s
  end

  test 'grade_to_s returns grade text for single pitch' do
    assert_equal '6a', @route_one.grade_to_s
  end

  test 'app_path returns correct path' do
    assert_equal "/crag-routes/#{@route_one.id}/#{@route_one.slug_name}", @route_one.app_path
  end

  test 'latitude and longitude returns crag coordinates if no sector' do
    assert_equal @route_one.crag.latitude, @route_one.latitude
    assert_equal @route_one.crag.longitude, @route_one.longitude
  end

  test 'latitude and longitude returns sector coordinates if sector present' do
    assert_equal @route_two.crag_sector.latitude, @route_two.latitude
    assert_equal @route_two.crag_sector.longitude, @route_two.longitude
  end

  test 'historize_location sets location before validation' do
    route = CragRoute.new(
      name: 'New Route',
      crag: crags(:rocher_des_aures),
      climbing_type: 'sport_climbing',
      sections: [{ grade: '6a', climbing_type: 'sport_climbing' }]
    )
    route.valid?
    assert_equal [route.crag.latitude.to_s, route.crag.longitude.to_s], route.location
  end

  test 'historize_grade_gap sets grade values and texts' do
    route = CragRoute.new(
      name: 'Gap Route',
      crag: crags(:rocher_des_aures),
      climbing_type: 'multi_pitch',
      sections: [
        { grade: '5c', climbing_type: 'sport_climbing' },
        { grade: '6a', climbing_type: 'sport_climbing' }
      ]
    )
    route.save
    assert_equal '5c', route.min_grade_text
    assert_equal '6a', route.max_grade_text
    assert_equal Grade.to_value('5c'), route.min_grade_value
    assert_equal Grade.to_value('6a'), route.max_grade_value
  end

  test 'validate_sections ensures grade is present' do
    @route_one.sections = [{ climbing_type: 'sport_climbing' }]
    assert @route_one.invalid?
  end

  test 'validate_sections ensures grade is valid if present' do
    @route_one.sections = [{ grade: '12z', climbing_type: 'sport_climbing' }]
    assert @route_one.invalid?
    assert_includes @route_one.errors[:grade], I18n.t('activerecord.errors.messages.inclusion')
  end
end
