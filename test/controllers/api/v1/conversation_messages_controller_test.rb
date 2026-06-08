# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ConversationMessagesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @conversation = conversations(:conversation_1)
        @message = conversation_messages(:message_1)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_conversation_conversation_messages_url(@conversation), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_not_empty json_response
      end

      test 'should get last messages' do
        get last_messages_api_v1_conversation_conversation_messages_url(@conversation),
            params: { posted_after_at: (Time.current - 2.hours).to_s },
            headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show message' do
        get api_v1_conversation_conversation_message_url(@conversation, @message), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @message.id, json_response['id']
      end

      test 'should create message' do
        assert_difference('ConversationMessage.count') do
          post api_v1_conversation_conversation_messages_url(@conversation),
               params: { conversation_message: { body: 'New message' } },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update message' do
        put api_v1_conversation_conversation_message_url(@conversation, @message),
            params: { conversation_message: { body: 'Updated message' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @message.reload
        assert_equal 'Updated message', @message.body
      end

      test 'should not update message of another user' do
        put api_v1_conversation_conversation_message_url(@conversation, @message),
            params: { conversation_message: { body: 'Try to update' } },
            headers: @other_user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy message' do
        assert_difference('ConversationMessage.count', -1) do
          delete api_v1_conversation_conversation_message_url(@conversation, @message),
                 headers: @user_headers,
                 as: :json
        end
        assert_response :success
      end

      test 'should not access messages of a conversation user is not part of' do
        new_conversation = Conversation.create!
        other_user_2 = User.create!(
          first_name: 'Other',
          last_name: 'User',
          email: 'other@test.com',
          password: 'Password123!',
          uuid: SecureRandom.uuid,
          slug_name: 'other-user'
        )
        ConversationUser.create!(conversation: new_conversation, user: @other_user)
        ConversationUser.create!(conversation: new_conversation, user: other_user_2)

        get api_v1_conversation_conversation_messages_url(new_conversation), headers: @user_headers
        assert_response :forbidden
      end
    end
  end
end
