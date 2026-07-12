# frozen_string_literal: true

require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @notification = notifications(:new_message_notif)
    @user = users(:normal_user)
  end

  test 'notification is valid' do
    assert @notification.valid?
  end

  test 'notification is invalid without notification_type' do
    @notification.notification_type = nil
    assert @notification.invalid?
    assert_includes @notification.errors.attribute_names, :notification_type
  end

  test 'notification is invalid with wrong notifiable_type' do
    @notification.notifiable_type = 'Crag'
    assert @notification.invalid?
    assert_includes @notification.errors.attribute_names, :notifiable_type
  end

  test 'notification is invalid with wrong notification_type' do
    @notification.notification_type = 'wrong_type'
    assert @notification.invalid?
    assert_includes @notification.errors.attribute_names, :notification_type
  end

  test 'posted_at is set before validation' do
    notif = Notification.new(
      user: @user,
      notifiable: users(:super_admin_user),
      notification_type: 'new_follower'
    )
    notif.valid?
    assert_not_nil notif.posted_at
  end

  test 'name returns correct name for User notifiable' do
    notif = notifications(:new_follower_notif)
    assert_equal users(:super_admin_user).first_name, notif.name
  end

  test 'name returns correct name for ConversationMessage notifiable' do
    notif = notifications(:new_message_notif)
    assert_equal @user.first_name, notif.name
  end

  test 'app_path returns correct path for new_message' do
    notif = notifications(:new_message_notif)
    assert_equal conversation_messages(:message_1).app_path, notif.app_path
  end

  test 'summary_to_json and detail_to_json return expected structure' do
    json = @notification.detail_to_json
    assert_equal @notification.id, json[:id]
    assert_equal @notification.notification_type, json[:notification_type]
    assert_equal @notification.notifiable_type, json[:notifiable_type]
    assert_equal @notification.notifiable_id, json[:notifiable_id]
    assert json.key?(:notifiable_object)
    assert json.key?(:parent_object)
  end

  test 'readable concern methods' do
    assert @notification.unread?
    assert_not @notification.read?

    @notification.read!
    assert @notification.read?
    assert_not @notification.unread?
    assert_not_nil @notification.read_at

    @notification.unread!
    assert @notification.unread?
    assert_nil @notification.read_at
  end

  test 'send_email_notification calls EmailNotificationWorker if enabled' do
    @user.update_column(:email_notifiable_list, ['new_message'])

    ActionCable.server.stub :broadcast, true do
      mock_set = Minitest::Mock.new
      mock_set.expect(:perform_later, true, [Integer])

      EmailNotificationJob.stub :set, lambda { |options|
        assert_equal 5.minutes, options[:wait]
        mock_set
      } do
        Notification.create!(
          user: @user,
          notifiable: conversation_messages(:message_2),
          notification_type: 'new_message'
        )
      end
      assert_mock mock_set
    end
  end

  test 'name returns correct name for Article notifiable' do
    article = articles(:article_1)
    notif = Notification.new(user: @user, notifiable: article, notification_type: 'new_article')
    assert_equal article.name, notif.name
  end

  test 'name returns correct name for Like notifiable' do
    like = likes(:gym_route_like)
    notif = Notification.new(user: @user, notifiable: like, notification_type: 'new_like')
    assert_equal like.user.first_name, notif.name
  end

  test 'app_path returns correct path for new_like' do
    like = likes(:gym_route_like)
    notif = Notification.new(user: @user, notifiable: like, notification_type: 'new_like')
    assert_equal like.likeable.app_path, notif.app_path
  end

  test 'broadcast_notification is called after save' do
    mock_server = Minitest::Mock.new
    mock_server.expect(:broadcast, true, [String, TrueClass])

    ActionCable.stub :server, mock_server do
      @notification.save
    end
    assert_mock mock_server
  end
end
