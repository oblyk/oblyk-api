# frozen_string_literal: true

require 'test_helper'

class EmailNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  setup do
    @new_message_notif = notifications(:new_message_notif)
    @new_follower_notif = notifications(:new_follower_notif)

    @new_message_notif.user.update_column(:email_notifiable_list, Notification::EMAILABLE_NOTIFICATION_LIST)
    @new_follower_notif.user.update_column(:email_notifiable_list, Notification::EMAILABLE_NOTIFICATION_LIST)
  end

  test 'it sends email for new_message' do
    assert_emails 1 do
      EmailNotificationJob.perform_now(@new_message_notif.id)
    end
  end

  test 'it sends email for request_for_follow_up' do
    @new_follower_notif.update_column(:notification_type, 'request_for_follow_up')

    assert_emails 1 do
      EmailNotificationJob.perform_now(@new_follower_notif.id)
    end
  end

  test 'it does nothing if notification is read' do
    @new_message_notif.update_column(:read_at, Time.current)

    assert_emails 0 do
      EmailNotificationJob.perform_now(@new_message_notif.id)
    end
  end

  test 'it does nothing for new_publication' do
    notification = Notification.create!(
      user: users(:normal_user),
      notifiable: users(:normal_user), # Juste pour avoir un notifiable valide
      notification_type: 'new_publication'
    )

    assert_emails 0 do
      EmailNotificationJob.perform_now(notification.id)
    end
  end

  test 'it raises error if notification does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      EmailNotificationJob.perform_now(0)
    end
  end
end
