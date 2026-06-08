# frozen_string_literal: true

require 'test_helper'

class ConversationUserTest < ActiveSupport::TestCase
  setup do
    @conversation_user = conversation_users(:conversation_1_jean)
    @user = users(:normal_user)
    @conversation = conversations(:conversation_1)
  end

  test 'read! updates last_read_at' do
    previous_read_at = @conversation_user.last_read_at
    @conversation_user.read!
    assert @conversation_user.last_read_at > previous_read_at
  end

  test 'read! marks notifications as read' do
    message = conversation_messages(:message_2)
    notification = Notification.create!(
      notification_type: 'new_message',
      user: @user,
      notifiable: message,
      read_at: nil
    )

    assert_not notification.read?

    @conversation_user.read!

    notification.reload
    assert notification.read?
  end
end
