# frozen_string_literal: true

require 'test_helper'

class GymSpaceSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_space = gym_spaces(:my_gym_boulder_space)
    @serializer = GymSpaceSerializer.new(@gym_space)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_space.id, attributes['id']
    assert_equal @gym_space.name, attributes['name']
    assert_equal @gym_space.slug_name, attributes['slug_name']
    assert_equal @gym_space.app_path, attributes['app_path']
    assert_equal @gym_space.description, attributes['description']
    assert_equal @gym_space.order, attributes['order']
    assert_equal @gym_space.climbing_type, attributes['climbing_type']
    assert_equal @gym_space.gym_space_group_id, attributes['gym_space_group_id']
    assert_equal @gym_space.draft, attributes['draft']
    assert_equal @gym_space.representation_type, attributes['representation_type']
    assert_equal @gym_space.three_d?, attributes['have_three_d']
    assert_equal Color.black_or_white_rgb(@gym_space.sectors_color || 'rgb(0,0,0)'), attributes['text_contrast_color']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym']
    assert_equal @gym_space.gym_id, relationships['gym']['data']['id'].to_i
  end

  test 'It contains figures when requested' do
    serializer = GymSpaceSerializer.new(@gym_space, params: { with_figures: true })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    attributes = serialization['data']['attributes']
    assert_not_nil attributes['figures']
    assert_kind_of Integer, attributes['figures']['routes_count']
  end
end
