# frozen_string_literal: true

require 'test_helper'

class GymOpenerSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_opener = gym_openers(:opener_one)
    @serializer = GymOpenerSerializer.new(@gym_opener)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_opener.id, attributes['id']
    assert_equal @gym_opener.name, attributes['name']
    assert_equal @gym_opener.first_name, attributes['first_name']
    assert_equal @gym_opener.last_name, attributes['last_name']
    assert_equal @gym_opener.gym_id, attributes['gym_id']
    assert_equal @gym_opener.created_at.as_json, attributes['history']['created_at']
    assert_equal @gym_opener.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['gym']
    assert_not_nil relationships['user']
    assert_equal @gym_opener.gym_id, relationships['gym']['data']['id'].to_i
    assert_equal @gym_opener.user_id, relationships['user']['data']['id'].to_i
  end
end
