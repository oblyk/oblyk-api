# frozen_string_literal: true

require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  setup do
    @conversation = conversations(:conversation_1)
  end

  test 'conversation has users' do
    assert_equal 2, @conversation.users.size
    assert_includes @conversation.users, users(:normal_user)
    assert_includes @conversation.users, users(:super_admin_user)
  end

  test 'update_last_message_at! updates last_message_at attribute' do
    last_message = @conversation.conversation_messages.order(:posted_at).last
    new_date = Time.current + 1.day
    last_message.update_column(:posted_at, new_date)

    @conversation.update_last_message_at!
    @conversation.reload

    assert_equal new_date.to_i, @conversation.last_message_at.to_i
  end

  test 'same_conversation returns existing conversation with same users' do
    new_conversation = Conversation.new
    new_conversation.conversation_users.build(user: users(:normal_user))
    new_conversation.conversation_users.build(user: users(:super_admin_user))

    found_conversation = new_conversation.same_conversation
    assert_equal @conversation.id, found_conversation.id
  end

  test 'detail_to_json returns expected structure' do
    json = @conversation.detail_to_json
    assert_equal @conversation.id, json[:id]
    assert_equal 2, json[:conversation_users].size
    assert_not_nil json[:last_message]
    assert_equal conversation_messages(:message_2).body, json[:last_message][:body]
  end
end
