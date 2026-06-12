# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymRouteSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_route = gym_routes(:gym_route_one)
    @serializer = Embedded::GymRouteSerializer.new(@gym_route)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_route.id, attributes['id']
    assert_equal @gym_route.name, attributes['name']
    assert_equal @gym_route.climbing_type, attributes['climbing_type']
    assert_equal @gym_route.gym_sector_id, attributes['gym_sector_id']
  end

  test 'It contains the grade_gap attribute' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_route.max_grade_value, attributes['grade_gap']['max_grade_value']
    assert_equal @gym_route.min_grade_value, attributes['grade_gap']['min_grade_value']
    assert_equal @gym_route.max_grade_text, attributes['grade_gap']['max_grade_text']
    assert_equal @gym_route.min_grade_text, attributes['grade_gap']['min_grade_text']
  end

  test 'It contains the gym_sector relationship' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_sector']
    assert_equal @gym_route.gym_sector_id, relationships['gym_sector']['data']['id'].to_i
  end
end
