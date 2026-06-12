# frozen_string_literal: true

require 'test_helper'

class AscentUserSerializerTest < ActiveSupport::TestCase
  setup do
    @ascent_user = ascent_users(:ascent_user_one)
    @serializer = AscentUserSerializer.new(@ascent_user)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @ascent_user.id, attributes['id']

    assert_not_nil attributes['history']
    assert_equal @ascent_user.created_at.as_json, attributes['history']['created_at']
    assert_equal @ascent_user.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It may include user if specified' do
    serializer = AscentUserSerializer.new(@ascent_user, { include: [:user] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'user' }
  end
end
