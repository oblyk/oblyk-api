# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymSpaceSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_space = gym_spaces(:my_gym_boulder_space)
    @serializer = Embedded::GymSpaceSerializer.new(@gym_space)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_space.id, attributes['id']
    assert_equal @gym_space.name, attributes['name']
    assert_equal @gym_space.climbing_type, attributes['climbing_type']
  end

  test 'It contains the relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_sectors']
  end
end
