# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Sessions
      class SigninControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:normal_user)
          @headers = api_access_token_headers
        end

        test 'should sign in with correct credentials' do
          post api_v1_sessions_sign_in_url,
               params: { email: @user.email, password: 'JeanJack@1234' },
               headers: @headers,
               as: :json

          assert_response :created
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['token']
          assert_not_nil json_response['refresh_token']
        end

        test 'should not sign in with incorrect password' do
          post api_v1_sessions_sign_in_url,
               params: { email: @user.email, password: 'wrong_password' },
               headers: @headers,
               as: :json

          assert_response :unprocessable_entity
          json_response = JSON.parse(response.body)
          assert_equal ['email_or_password_suite_not_find'], json_response['error']['base']
        end

        test 'should not sign in with non-existent email' do
          post api_v1_sessions_sign_in_url,
               params: { email: 'nonexistent@mail.com', password: 'password' },
               headers: @headers,
               as: :json

          assert_response :unprocessable_entity
        end

        test 'should return no content on destroy' do
          delete api_v1_sessions_sign_in_url,
                 headers: @headers,
                 as: :json
          assert_response :no_content
        end
      end
    end
  end
end
