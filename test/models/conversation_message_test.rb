# frozen_string_literal: true

require 'test_helper'

class ConversationMessageTest < ActiveSupport::TestCase
  setup do
    @conversation = conversations(:conversation_1)
    @jean = users(:normal_user)
    @super_jean = users(:super_admin_user)
  end

  test 'init_posted_at before validation' do
    message = ConversationMessage.new(body: 'test', conversation: @conversation, user: @jean)
    message.valid?
    assert_not_nil message.posted_at
  end

  test 'after_create update_last_message_at! on conversation' do
    previous_last_message_at = @conversation.last_message_at

    ConversationMessage.create!(
      body: 'New message',
      conversation: @conversation,
      user: @jean
    )

    @conversation.reload
    assert @conversation.last_message_at > previous_last_message_at
  end

  test 'after_create update_last_read! on conversation_user' do
    conv_user = conversation_users(:conversation_1_jean)
    conv_user.update_column(:last_read_at, 1.day.ago)

    ConversationMessage.create!(
      body: 'Read me',
      conversation: @conversation,
      user: @jean
    )

    conv_user.reload
    assert conv_user.last_read_at > 1.hour.ago
  end

  test 'after_create notify! other users' do
    assert_difference 'Notification.count', 1 do
      @conversation_message = ConversationMessage.create!(
        body: 'Notification test',
        conversation: @conversation,
        user: @jean
      )
    end

    notification = Notification.where(notifiable: @conversation_message).last
    assert_equal 'new_message', notification.notification_type
    assert_equal @super_jean.id, notification.user_id
  end

  test 'notify! does not create duplicate notification for same conversation' do
    ConversationMessage.create!(
      body: 'First message',
      conversation: @conversation,
      user: @jean
    )

    assert_no_difference 'Notification.count' do
      ConversationMessage.create!(
        body: 'Second message',
        conversation: @conversation,
        user: @jean
      )
    end
  end

  test 'detail_to_json returns expected structure' do
    message = conversation_messages(:message_1)
    json = message.detail_to_json
    assert_equal message.id, json[:id]
    assert_equal message.body, json[:body]
    assert_not_nil json[:creator]
  end
end
