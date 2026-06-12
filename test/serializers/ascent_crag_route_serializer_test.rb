# frozen_string_literal: true

require 'test_helper'

class AscentCragRouteSerializerTest < ActiveSupport::TestCase
  setup do
    @ascent_crag_route = ascent_crag_routes(:crag_ascent_one)
    @serializer = AscentCragRouteSerializer.new(@ascent_crag_route)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @ascent_crag_route.id, attributes['id']
    assert_equal @ascent_crag_route.ascent_status, attributes['ascent_status']
    assert_equal @ascent_crag_route.roping_status, attributes['roping_status']
    assert_equal @ascent_crag_route.crag_route_id, attributes['crag_route_id']
    assert_equal @ascent_crag_route.sections, attributes['sections']
    assert_equal @ascent_crag_route.height, attributes['height']
    assert_equal @ascent_crag_route.sections_count, attributes['sections_count']
    assert_equal @ascent_crag_route.max_grade_value, attributes['max_grade_value']
    assert_equal @ascent_crag_route.min_grade_value, attributes['min_grade_value']
    assert_equal @ascent_crag_route.max_grade_text, attributes['max_grade_text']
    assert_equal @ascent_crag_route.min_grade_text, attributes['min_grade_text']
    assert_equal @ascent_crag_route.released_at.as_json, attributes['released_at']
    assert_equal @ascent_crag_route.sections_done, attributes['sections_done']

    assert_not_nil attributes['history']
    assert_equal @ascent_crag_route.created_at.as_json, attributes['history']['created_at']
    assert_equal @ascent_crag_route.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It may include crag_route if specified' do
    serializer = AscentCragRouteSerializer.new(@ascent_crag_route, { include: [:crag_route] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'crag_route' }
  end

  test 'It may include crag if specified' do
    serializer = AscentCragRouteSerializer.new(@ascent_crag_route, { include: [:crag] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'crag' }
  end

  test 'It may include user if specified' do
    serializer = AscentCragRouteSerializer.new(@ascent_crag_route, { include: [:user] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'user' }
  end
end
