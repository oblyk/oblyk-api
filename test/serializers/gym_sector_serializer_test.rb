# frozen_string_literal: true

require 'test_helper'

class GymSectorSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_sector = gym_sectors(:my_gym_sector)
    @serializer = GymSectorSerializer.new(@gym_sector)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_sector.id, attributes['id']
    assert_equal @gym_sector.name, attributes['name']
    assert_equal @gym_sector.app_path, attributes['app_path']
    assert_equal @gym_sector.order, attributes['order']
    assert_equal @gym_sector.climbing_type, attributes['climbing_type']
    assert_equal @gym_sector.height, attributes['height']
    assert_equal @gym_sector.three_d_height.to_s, attributes['three_d_height'].to_s
    assert_equal @gym_sector.three_d_elevated.to_s, attributes['three_d_elevated'].to_s
    assert_equal @gym_sector.gym_space_id, attributes['gym_space_id']
    assert_equal @gym_sector.can_be_more_than_one_pitch, attributes['can_be_more_than_one_pitch']
    assert_equal @gym_sector.anchor_ranges, attributes['anchor_ranges']
    assert_equal @gym_sector.three_d_path?, attributes['have_three_d_path']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_space']
    assert_not_nil relationships['gym']
    assert_equal @gym_sector.gym_space_id, relationships['gym_space']['data']['id'].to_i
    assert_equal @gym_sector.gym_id, relationships['gym']['data']['id'].to_i
  end
end
