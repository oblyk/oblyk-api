# frozen_string_literal: true

require 'test_helper'

class CragRouteSerializerTest < ActiveSupport::TestCase
  setup do
    @crag_route = crag_routes(:route_one)
    @serializer = CragRouteSerializer.new(@crag_route)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @crag_route.id, attributes['id']
    assert_equal @crag_route.name, attributes['name']
    if @crag_route.slug_name
      assert_equal @crag_route.slug_name, attributes['slug_name']
    else
      assert_nil attributes['slug_name']
    end
    assert_equal @crag_route.height, attributes['height']
    assert_equal @crag_route.climbing_type, attributes['climbing_type']
    assert_equal @crag_route.sections_count, attributes['sections_count']
    assert_equal @crag_route.crag_id, attributes['crag_id']
    assert_equal @crag_route.grade_to_s, attributes['grade_to_s']
    assert_equal @crag_route.app_path, attributes['app_path']
  end

  test 'It contains the grade_gap attribute' do
    attributes = @serialization['data']['attributes']
    assert_equal @crag_route.max_grade_value, attributes['grade_gap']['max_grade_value']
    assert_equal @crag_route.min_grade_value, attributes['grade_gap']['min_grade_value']
    assert_equal @crag_route.max_grade_text, attributes['grade_gap']['max_grade_text']
    assert_equal @crag_route.min_grade_text, attributes['grade_gap']['min_grade_text']
  end

  test 'It contains the photo attribute' do
    attributes = @serialization['data']['attributes']
    assert attributes.key?('photo')
    assert attributes['photo'].key?('id')
    assert attributes['photo'].key?('attachments')
  end

  test 'It contains the relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['crag']
    assert_equal @crag_route.crag_id, relationships['crag']['data']['id'].to_i
  end
end
