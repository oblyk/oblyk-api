# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ConversationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @conversation = conversations(:conversation_1)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_conversations_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_includes json_response.map { |c| c['id'] }, @conversation.id
      end

      test 'should show conversation' do
        get api_v1_conversation_url(@conversation), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @conversation.id, json_response['id']
      end

      test 'should not show conversation if user is not part of it' do
        new_conversation = Conversation.create!

        get api_v1_conversation_url(new_conversation), headers: @user_headers
        assert_response :forbidden
      end

      test 'should create conversation' do
        third_user = User.create!(
          first_name: 'Third',
          last_name: 'User',
          email: 'third@test.com',
          password: 'Password123!',
          uuid: SecureRandom.uuid,
          slug_name: 'third-user'
        )
        assert_difference('Conversation.count') do
          post api_v1_conversations_url,
               params: {
                 conversation: {
                   conversation_users_attributes: [
                     { user_id: @user.id },
                     { user_id: third_user.id }
                   ]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should return existing conversation if it already exists' do
        assert_no_difference('Conversation.count') do
          post api_v1_conversations_url,
               params: {
                 conversation: {
                   conversation_users_attributes: [
                     { user_id: @user.id },
                     { user_id: @other_user.id }
                   ]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @conversation.id, json_response['id']
      end

      test 'should mark conversation as read' do
        post read_api_v1_conversation_url(@conversation), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('last_read_at')
      end
    end
  end
end
