# frozen_string_literal: true

require 'test_helper'

class ConversationMessageSerializerTest < ActiveSupport::TestCase
  setup do
    @conversation_message = conversation_messages(:message_1)
    @serializer = ConversationMessageSerializer.new(@conversation_message)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @conversation_message.id, attributes['id']
    assert_equal @conversation_message.conversation_id, attributes['conversation_id']
    assert_equal @conversation_message.body, attributes['body']
    assert_equal @conversation_message.posted_at.as_json, attributes['posted_at']
    assert_equal @conversation_message.created_at.as_json, attributes['history']['created_at']
    assert_equal @conversation_message.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains the user relationship' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['user']
    assert_equal @conversation_message.user_id, relationships['user']['data']['id'].to_i
  end
end
