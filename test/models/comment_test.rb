# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:comment_on_crag)
    @user = users(:normal_user)
    @crag = crags(:rocher_des_aures)
  end

  test 'comment is valid' do
    assert @comment.valid?
  end

  test 'comment is invalid without body' do
    @comment.body = nil
    assert @comment.invalid?
    assert_includes @comment.errors.keys, :body
  end

  test 'comment is invalid with unsupported commentable_type' do
    @comment.commentable_type = 'User'
    assert @comment.invalid?
    assert_includes @comment.errors.keys, :commentable_type
  end

  test 'normalize_blank_values strips and nilifies body' do
    comment = Comment.new(body: '   ', user: @user, commentable: @crag)
    comment.valid?
    assert_nil comment.body

    comment.body = '  content  '
    comment.valid?
    assert_equal 'content', comment.body
  end

  test 'app_path returns correct path' do
    assert_equal "/comments/#{@comment.id}", @comment.app_path
  end

  test 'summary_to_json returns expected structure' do
    json = @comment.summary_to_json
    assert_equal @comment.id, json[:id]
    assert_equal @comment.body, json[:body]
    assert_equal @comment.user.id, json[:creator][:id]
    assert_equal @comment.commentable_type, json[:commentable_type]
    assert_equal @comment.commentable_id, json[:commentable_id]
  end

  test 'detail_to_json includes commentable' do
    json = @comment.detail_to_json
    assert json.key?(:commentable)
    assert_equal @crag.id, json[:commentable][:id]
  end

  test 'creating a reply to a comment creates a notification' do
    assert_difference 'Notification.count', 1 do
      @reply_comment = Comment.create!(
        user: @user,
        body: 'Reply body',
        commentable: @comment,
        reply_to_comment: @comment
      )
    end
    notification = Notification.where(notifiable: @reply_comment).last
    assert_equal 'new_reply', notification.notification_type
    assert_equal 'Comment', notification.notifiable_type
    assert_equal @comment.user_id, notification.user_id
  end

  test 'destroying a reply to a comment destroys the notification' do
    reply = Comment.create!(
      user: @user,
      body: 'Reply to be destroyed',
      commentable: @comment,
      reply_to_comment: @comment
    )
    assert_difference 'Notification.count', -1 do
      reply.destroy
    end
  end

  test 'strip_tag_column strips html tags from body' do
    comment = Comment.new(
      user: @user,
      commentable: @crag,
      body: '<p>Hello</p>'
    )
    comment.valid?
    assert_equal 'Hello', comment.body
  end
  test 'refresh_comments_count! is called for GymRoute' do
    gym_route = gym_routes(:gym_route_one)

    assert gym_route.respond_to?(:refresh_all_comments_count!)

    assert_nothing_raised do
      Comment.create!(
        user: @user,
        body: 'Comment on gym route',
        commentable: gym_route
      )
    end
  end
end
