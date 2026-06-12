# frozen_string_literal: true

require 'test_helper'

class EmbeddedVideoSerializerTest < ActiveSupport::TestCase
  setup do
    @video = videos(:video_youtube)
    @serializer = Embedded::VideoSerializer.new(@video)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @video.id, attributes['id']
    assert_equal @video.url, attributes['url']
    assert_equal @video.video_service, attributes['video_service']
    assert_equal @video.viewable_type, attributes['viewable_type']
    assert_equal @video.viewable_id, attributes['viewable_id']
  end

  test 'It contains the history attribute' do
    attributes = @serialization['data']['attributes']
    assert_equal @video.created_at.as_json, attributes['history']['created_at']
    assert_equal @video.updated_at.as_json, attributes['history']['updated_at']
  end
end
