# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Sessions
      class SignupControllerTest < ActionDispatch::IntegrationTest
        setup do
          @headers = api_access_token_headers
          @user_params = {
            email: 'newuser@mail.com',
            first_name: 'New',
            last_name: 'User',
            password: 'Password@123',
            password_confirmation: 'Password@123'
          }
        end

        test 'should sign up with valid params' do
          assert_difference 'User.count', 1 do
            post api_v1_sessions_sign_up_url,
                 params: @user_params,
                 headers: @headers,
                 as: :json
          end

          assert_response :created
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['token']
          assert_not_nil json_response['refresh_token']
        end

        test 'should sign up and subscribe to newsletter' do
          assert_difference ['User.count', 'Subscribe.count'], 1 do
            post api_v1_sessions_sign_up_url,
                 params: @user_params.merge(newsletter_subscribe: true),
                 headers: @headers,
                 as: :json
          end

          assert_response :created
        end

        test 'should not sign up with invalid params' do
          assert_no_difference 'User.count' do
            post api_v1_sessions_sign_up_url,
                 params: @user_params.merge(email: 'invalid-email'),
                 headers: @headers,
                 as: :json
          end

          assert_response :unprocessable_entity
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['error']
        end

        test 'should not sign up if email already taken' do
          existing_user = users(:normal_user)
          assert_no_difference 'User.count' do
            post api_v1_sessions_sign_up_url,
                 params: @user_params.merge(email: existing_user.email),
                 headers: @headers,
                 as: :json
          end

          assert_response :unprocessable_entity
        end
      end
    end
  end
end
