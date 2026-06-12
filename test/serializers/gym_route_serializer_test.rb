# frozen_string_literal: true

require 'test_helper'

class GymRouteSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_route = gym_routes(:gym_route_one)
    @serializer = GymRouteSerializer.new(@gym_route)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_route.id, attributes['id']
    assert_equal @gym_route.name, attributes['name']
    assert_equal @gym_route.height, attributes['height']
    assert_equal @gym_route.climbing_type, attributes['climbing_type']
    assert_equal @gym_route.opened_at.as_json, attributes['opened_at']
    assert_equal @gym_route.hold_colors, attributes['hold_colors']
    assert_equal @gym_route.tag_colors, attributes['tag_colors']
    assert_equal JSON.parse(@gym_route.sections.to_json), attributes['sections']
    assert_equal @gym_route.sections_count, attributes['sections_count']
    assert_equal @gym_route.gym_sector_id, attributes['gym_sector_id']
    assert_equal @gym_route.short_app_path, attributes['short_app_path']
    assert_equal @gym_route.updated_at.as_json, attributes['updated_at']
    assert_equal @gym_route.all_comments_count, attributes['all_comments_count']
    assert_equal @gym_route.gym_space_app_path, attributes['gym_space_app_path']
    assert_equal @gym_route.dismounted?, attributes['dismounted']
    assert_equal @gym_route.grade_to_s, attributes['grade_to_s']
    assert_equal @gym_route.gym_sector.name, attributes['gym_sector_name']
    assert_equal @gym_route.max_grade_value, attributes['grade_gap']['max_grade_value']
    assert_equal @gym_route.min_grade_value, attributes['grade_gap']['min_grade_value']
    assert_equal @gym_route.max_grade_text, attributes['grade_gap']['max_grade_text']
    assert_equal @gym_route.min_grade_text, attributes['grade_gap']['min_grade_text']
    assert_equal @gym_route.created_at.as_json, attributes['history']['created_at']
    assert_equal @gym_route.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_space']
    assert_not_nil relationships['gym_sector']
    assert_equal @gym_route.gym_space_id, relationships['gym_space']['data']['id'].to_i
    assert_equal @gym_route.gym_sector_id, relationships['gym_sector']['data']['id'].to_i
  end
end
