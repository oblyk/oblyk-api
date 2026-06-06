# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Sessions
      class TokenControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:normal_user)
          @headers = api_access_token_headers

          # Generate a refresh token for the user
          user_data = @user.as_json(only: %i[id first_name last_name])
          exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
          @refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)
        end

        test 'should refresh token with valid refresh token' do
          post api_v1_sessions_tokens_url,
               params: { refresh_token: @refresh_token },
               headers: @headers,
               as: :json

          assert_response :created
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['token']
          assert_not_nil json_response['refresh_token']
        end

        test 'should not refresh token with invalid refresh token' do
          post api_v1_sessions_tokens_url,
               params: { refresh_token: 'invalid_token' },
               headers: @headers,
               as: :json

          assert_equal 419, response.status
        end

        test 'should not refresh token for non-existent user' do
          user_data = { id: 99_999 }
          exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
          token = JwtToken::Token.generate(user_data, exp + 3.months)

          post api_v1_sessions_tokens_url,
               params: { refresh_token: token },
               headers: @headers,
               as: :json

          assert_equal 419, response.status
        end
      end
    end
  end
end
