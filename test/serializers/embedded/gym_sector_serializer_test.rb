# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymSectorSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_sector = gym_sectors(:my_gym_sector)
    @serializer = Embedded::GymSectorSerializer.new(@gym_sector)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_sector.id, attributes['id']
    assert_equal @gym_sector.name, attributes['name']
    assert_equal @gym_sector.climbing_type, attributes['climbing_type']
    assert_equal @gym_sector.gym_space_id, attributes['gym_space_id']
  end

  test 'It contains the gym_space relationship' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_space']
    assert_equal @gym_sector.gym_space_id, relationships['gym_space']['data']['id'].to_i
  end
end
