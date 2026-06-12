# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymThreeDElementSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_three_d_element = gym_three_d_elements(:element_1)
    @serializer = Embedded::GymThreeDElementSerializer.new(@gym_three_d_element)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_three_d_element.id, attributes['id']
    assert_equal @gym_three_d_element.gym_space_id, attributes['gym_space_id']
    assert_equal @gym_three_d_element.three_d_position, attributes['three_d_position']
  end

  test 'It contains the relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym_three_d_asset']
    assert_equal @gym_three_d_element.gym_three_d_asset_id, relationships['gym_three_d_asset']['data']['id'].to_i
  end
end
