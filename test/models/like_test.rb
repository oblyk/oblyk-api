# frozen_string_literal: true

require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  setup do
    @gym_route_like = likes(:gym_route_like)
    @comment_like = likes(:comment_like)
    @user = users(:normal_user)
  end

  test 'like is valid' do
    assert @gym_route_like.valid?
    assert @comment_like.valid?
  end

  test 'summary_to_json returns a hash' do
    summary = @gym_route_like.summary_to_json
    assert_kind_of Hash, summary
    assert_equal @gym_route_like.id, summary[:id]
    assert_equal 'GymRoute', summary[:likeable_type]
    assert_respond_to summary, :[]
    assert summary.key?(:likeable_likes_count)
  end

  test 'detail_to_json returns summary_to_json' do
    assert_equal @gym_route_like.summary_to_json, @gym_route_like.detail_to_json
  end

  test 'creating a like on a Comment creates a notification' do
    comment = comments(:comment_on_crag)

    assert_difference 'Notification.count', 1 do
      @like = Like.create!(
        user: @user,
        likeable: comment
      )
    end

    notification = Notification.where(notifiable: @like).last
    assert_equal 'new_like', notification.notification_type
    assert_equal 'Like', notification.notifiable_type
    assert_equal comment.user_id, notification.user_id
  end

  test 'destroying a like on a Comment destroys the notification' do
    comment = comments(:comment_on_crag)
    like = Like.create!(
      user: @user,
      likeable: comment
    )

    assert_difference 'Notification.count', -1 do
      like.destroy
    end
  end

  test 'creating a like on a GymRoute does not create a notification' do
    gym_route = gym_routes(:gym_route_one)

    assert_no_difference 'Notification.count' do
      Like.create!(
        user: @user,
        likeable: gym_route
      )
    end
  end
end
