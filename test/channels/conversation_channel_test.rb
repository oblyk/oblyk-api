# frozen_string_literal: true

require 'test_helper'

class ConversationChannelTest < ActionCable::Channel::TestCase
  test 'subscribes to a conversation stream when user is part of it' do
    user = users(:normal_user)
    conversation = Conversation.create!
    ConversationUser.create!(user: user, conversation: conversation)

    stub_connection current_user: user
    subscribe conversation_id: conversation.id

    assert_has_stream "conversations_#{conversation.id}"
  end

  test 'does not subscribe to a conversation stream when user is not part of it' do
    user = users(:normal_user)
    other_user = users(:super_admin_user)
    conversation = Conversation.create!
    ConversationUser.create!(user: other_user, conversation: conversation)

    stub_connection current_user: user

    assert_raises ActiveRecord::RecordNotFound do
      subscribe conversation_id: conversation.id
    end
  end

  test 'unsubscribed stops all streams' do
    user = users(:normal_user)
    conversation = Conversation.create!
    ConversationUser.create!(user: user, conversation: conversation)

    stub_connection current_user: user
    subscribe conversation_id: conversation.id
    assert_has_stream "conversations_#{conversation.id}"

    unsubscribe
    assert_no_streams
  end
end
