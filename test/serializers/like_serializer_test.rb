# frozen_string_literal: true

require 'test_helper'

class LikeSerializerTest < ActiveSupport::TestCase
  setup do
    @like = likes(:gym_route_like)
    @serializer = LikeSerializer.new(@like)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @like.id, attributes['id']
    assert_equal @like.likeable_type, attributes['likeable_type']
    assert_equal @like.likeable_id, attributes['likeable_id']
    if @like.likeable.likes_count.nil?
      assert_nil attributes['likeable_likes_count']
    else
      assert_equal @like.likeable.likes_count, attributes['likeable_likes_count']
    end
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['likeable']
    assert_equal @like.likeable_id, relationships['likeable']['data']['id'].to_i
    assert_equal @like.likeable_type, relationships['likeable']['data']['type'].underscore.camelize
  end
end
