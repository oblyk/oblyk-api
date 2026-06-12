# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymSerializerTest < ActiveSupport::TestCase
  setup do
    @gym = gyms(:my_gym)
    @serializer = Embedded::GymSerializer.new(@gym)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym.id, attributes['id']
    assert_equal @gym.name, attributes['name']
    assert_equal @gym.app_path, attributes['app_path']
  end

  test 'It contains the relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_spaces']
    assert_not_nil relationships['gym_three_d_elements']
  end
end
