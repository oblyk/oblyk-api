# frozen_string_literal: true

require 'test_helper'

class CommentSerializerTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:comment_on_crag)
    @serializer = CommentSerializer.new(@comment)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @comment.id, attributes['id']
    assert_equal @comment.body, attributes['body']
    if @comment.likes_count.nil?
      assert_nil attributes['likes_count']
    else
      assert_equal @comment.likes_count, attributes['likes_count']
    end
    if @comment.comments_count.nil?
      assert_nil attributes['comments_count']
    else
      assert_equal @comment.comments_count, attributes['comments_count']
    end
    if @comment.reply_to_comment_id.nil?
      assert_nil attributes['reply_to_comment_id']
    else
      assert_equal @comment.reply_to_comment_id, attributes['reply_to_comment_id']
    end
    assert_equal @comment.commentable_type, attributes['commentable_type']
    assert_equal @comment.commentable_id, attributes['commentable_id']
    if @comment.moderated_at.nil?
      assert_nil attributes['moderated_at']
    else
      assert_equal @comment.moderated_at, attributes['moderated_at']
    end
    assert_equal @comment.created_at.as_json, attributes['history']['created_at']
    assert_equal @comment.updated_at.as_json, attributes['history']['updated_at']
    assert_not attributes['moderated']
  end

  test 'It hides body if moderated' do
    @comment.moderated_at = Time.zone.now
    serializer = CommentSerializer.new(@comment)
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    attributes = serialization['data']['attributes']

    assert_nil attributes['body']
    assert attributes['moderated']
  end

  test 'It includes user if specified' do
    serializer = CommentSerializer.new(@comment, { include: [:user] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'user' }
  end

  test 'It includes commentable if specified' do
    serializer = CommentSerializer.new(@comment, { include: [:commentable] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'crag' }
  end
end
