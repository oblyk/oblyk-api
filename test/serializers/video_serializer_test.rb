# frozen_string_literal: true

require 'test_helper'

class VideoSerializerTest < ActiveSupport::TestCase
  setup do
    @video = videos(:video_youtube)
    @serializer = VideoSerializer.new(@video)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @video.id, attributes['id']
    assert_equal @video.url, attributes['url']
    assert_equal @video.description, attributes['description']

    if @video.likes_count.nil?
      assert_nil attributes['likes_count']
    else
      assert_equal @video.likes_count, attributes['likes_count']
    end

    assert_equal @video.viewable_type, attributes['viewable_type']
    assert_equal @video.viewable_id, attributes['viewable_id']

    if @video.thumbnail_url.nil?
      assert_nil attributes['thumbnail_url']
    else
      assert_equal @video.thumbnail_url, attributes['thumbnail_url']
    end

    if @video.embedded_code.nil?
      assert_nil attributes['embedded_code']
    else
      assert_equal @video.embedded_code, attributes['embedded_code']
    end

    if @video.video_metadata.nil?
      assert_nil attributes['video_metadata']
    else
      assert_equal @video.video_metadata, attributes['video_metadata']
    end

    assert_equal @video.video_service, attributes['video_service']

    if @video.video_file_path.nil?
      assert_nil attributes['oblyk_video']['path']
    else
      assert_equal @video.video_file_path, attributes['oblyk_video']['path']
    end

    if @video.video_content_type.nil?
      assert_nil attributes['oblyk_video']['content_type']
    else
      assert_equal @video.video_content_type, attributes['oblyk_video']['content_type']
    end

    assert_equal @video.created_at.as_json, attributes['history']['created_at']
    assert_equal @video.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['viewable']
    assert_not_nil relationships['user']
  end
end
