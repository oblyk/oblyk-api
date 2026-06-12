# frozen_string_literal: true

require 'test_helper'

class AscentGymRouteSerializerTest < ActiveSupport::TestCase
  setup do
    @ascent_gym_route = ascent_gym_routes(:gym_ascent_one)
    @serializer = AscentGymRouteSerializer.new(@ascent_gym_route)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @ascent_gym_route.id, attributes['id']
    assert_equal @ascent_gym_route.ascent_status, attributes['ascent_status']
    assert_equal @ascent_gym_route.gym_route_id, attributes['gym_route_id']
    assert_equal @ascent_gym_route.sections, attributes['sections']
    assert_equal @ascent_gym_route.height, attributes['height']
    assert_equal @ascent_gym_route.quantity, attributes['quantity']
    assert_equal @ascent_gym_route.sections_count, attributes['sections_count']
    assert_equal @ascent_gym_route.max_grade_value, attributes['max_grade_value']
    assert_equal @ascent_gym_route.min_grade_value, attributes['min_grade_value']
    assert_equal @ascent_gym_route.max_grade_text, attributes['max_grade_text']
    assert_equal @ascent_gym_route.min_grade_text, attributes['min_grade_text']
    assert_equal @ascent_gym_route.released_at.as_json, attributes['released_at']
    assert_equal @ascent_gym_route.sections_done, attributes['sections_done']
    assert_equal @ascent_gym_route.climbing_type, attributes['climbing_type']

    expected_points = JSON.parse(@ascent_gym_route.points.to_json)
    assert_equal expected_points, attributes['points']

    assert_not_nil attributes['history']
    assert_equal @ascent_gym_route.created_at.as_json, attributes['history']['created_at']
    assert_equal @ascent_gym_route.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains ascent_comment if present' do
    comment = comments(:comment_on_crag)
    @ascent_gym_route.stub :ascent_comment, comment do
      serializer = AscentGymRouteSerializer.new(@ascent_gym_route)
      serialization = JSON.parse(serializer.serializable_hash.to_json)
      ascent_comment_attr = serialization['data']['attributes']['ascent_comment']
      assert_not_nil ascent_comment_attr
      assert_equal comment.id, ascent_comment_attr['id']
      assert_equal comment.body, ascent_comment_attr['body']
    end
  end

  test 'It may include gym_route if specified' do
    serializer = AscentGymRouteSerializer.new(@ascent_gym_route, { include: [:gym_route] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'gym_route' }
  end

  test 'It may include gym if specified' do
    serializer = AscentGymRouteSerializer.new(@ascent_gym_route, { include: [:gym] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'gym' }
  end

  test 'It may include user if specified' do
    serializer = AscentGymRouteSerializer.new(@ascent_gym_route, { include: [:user] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'user' }
  end
end
