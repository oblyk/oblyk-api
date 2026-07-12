# frozen_string_literal: true

require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  parallelize(workers: 1)

  setup do
    @user_follow_user = follows(:follow_user_to_user)
    @user_follow_user_pending = follows(:follow_user_to_user_pending)
    @user_follow_crag = follows(:follow_user_to_crag)
    @user = users(:normal_user)
    @target_user = users(:super_admin_user)
    @crag = crags(:rocher_des_aures)
    @gym = gyms(:my_gym)
  end

  test 'follow is valid' do
    assert @user_follow_user.valid?
    assert @user_follow_crag.valid?
  end

  test 'follow is invalid with wrong followable_type' do
    follow = Follow.new(user: @user, followable_type: 'Comment', followable_id: 1)
    assert_not follow.valid?
    assert_includes follow.errors.attribute_names, :followable_type
  end

  test 'accepted? returns true if accepted_at is present' do
    assert @user_follow_user.accepted?
    assert_not @user_follow_user_pending.accepted?
  end

  test 'accept! sets accepted_at' do
    @user_follow_user_pending.accept!
    assert @user_follow_user_pending.accepted?
    assert_not_nil @user_follow_user_pending.accepted_at
  end

  test 'increment! increments views' do
    initial_views = @user_follow_user.views
    @user_follow_user.increment!
    assert_equal initial_views + 1, @user_follow_user.views
  end

  test 'reject! deletes the follow' do
    assert_difference 'Follow.count', -1 do
      @user_follow_user.reject!
    end
  end

  test 'auto_accepted for Crag, Gym and GuideBookPaper' do
    follow_crag = Follow.create(user: @user, followable: @crag)
    assert follow_crag.accepted?

    follow_gym = Follow.create(user: @user, followable: @gym)
    assert follow_gym.accepted?
  end

  test 'auto_accepted for User depends on public_profile' do
    @target_user.update_column(:public_profile, true)
    follow_public_user = Follow.create(user: @user, followable: @target_user)
    assert follow_public_user.accepted?

    @target_user.update_column(:public_profile, false)
    follow_private_user = Follow.create(user: @user, followable: @target_user)
    assert_not follow_private_user.accepted?
  end

  test 'accepted scope returns only accepted follows' do
    accepted_follows = Follow.accepted
    assert_includes accepted_follows, @user_follow_user
    assert_not_includes accepted_follows, @user_follow_user_pending
  end

  test 'awaiting_acceptance scope returns only pending follows' do
    pending_follows = Follow.awaiting_acceptance
    assert_includes pending_follows, @user_follow_user_pending
    assert_not_includes pending_follows, @user_follow_user
  end

  test 'start_following_notify! creates notification when following a User' do
    Follow.delete_all
    Notification.delete_all

    @target_user.update_column(:public_profile, true)
    assert_difference -> { Notification.where(user_id: @target_user.id, notification_type: 'new_follower').count }, 1 do
      Follow.create!(user: @user, followable: @target_user)
    end

    @target_user.update_column(:public_profile, false)
    user2 = users(:super_admin_user)
    @user.update_column(:public_profile, false)
    assert_difference -> { Notification.where(user_id: @user.id, notification_type: 'request_for_follow_up').count }, 1 do
      Follow.create!(user: user2, followable: @user)
    end
  end

  test 'notify_accepted_change! creates notification when follow is accepted' do
    Follow.delete_all
    Notification.delete_all

    @target_user.update_column(:public_profile, false)
    follow = Follow.create!(user: @user, followable: @target_user)

    assert_difference -> { Notification.where(user_id: @user.id, notification_type: 'subscribe_accepted').count }, 1 do
      follow.accept!
    end
  end

  test 'destroy_follow_notification! removes related notifications' do
    Follow.delete_all
    Notification.delete_all

    @target_user.update_column(:public_profile, true)
    follow = Follow.create!(user: @user, followable: @target_user)

    assert_equal 1, Notification.where(user_id: @target_user.id, notification_type: 'new_follower').count

    assert_difference -> { Notification.where(user_id: @target_user.id, notification_type: 'new_follower').count }, -1 do
      follow.destroy
    end
  end
end
