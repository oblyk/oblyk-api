# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Sessions
      class PasswordControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:normal_user)
          @headers = api_access_token_headers
          Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
        end

        test 'should send reset password instructions' do
          post api_v1_sessions_reset_password_url,
               params: { email: @user.email },
               headers: @headers,
               as: :json

          assert_response :ok
        end

        test 'should not send reset password instructions for unknown email' do
          post api_v1_sessions_reset_password_url,
               params: { email: 'unknown@mail.com' },
               headers: @headers,
               as: :json

          assert_response :not_found
        end

        test 'should update password with valid token' do
          @user.update_columns(
            reset_password_token: 'valid_token',
            reset_password_token_expired_at: 1.hour.from_now
          )

          put api_v1_sessions_new_password_url,
              params: {
                token: 'valid_token',
                password: 'NewPassword@123',
                password_confirmation: 'NewPassword@123'
              },
              headers: @headers,
              as: :json

          assert_response :created
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['token']
          assert_not_nil json_response['refresh_token']

          @user.reload
          assert @user.authenticate('NewPassword@123')
          assert_nil @user.reset_password_token
        end

        test 'should not update password with expired token' do
          @user.update_columns(
            reset_password_token: 'expired_token',
            reset_password_token_expired_at: 1.hour.ago
          )

          put api_v1_sessions_new_password_url,
              params: {
                token: 'expired_token',
                password: 'NewPassword@123',
                password_confirmation: 'NewPassword@123'
              },
              headers: @headers,
              as: :json

          assert_response :unprocessable_entity
          json_response = JSON.parse(response.body)
          assert_equal 'Reset password token is expired', json_response['error']
        end

        test 'should not update password with invalid token' do
          put api_v1_sessions_new_password_url,
              params: {
                token: 'invalid_token',
                password: 'NewPassword@123',
                password_confirmation: 'NewPassword@123'
              },
              headers: @headers,
              as: :json

          assert_response :not_found
        end

        test 'should return errors with invalid password params' do
          @user.update_columns(
            reset_password_token: 'valid_token',
            reset_password_token_expired_at: 1.hour.from_now
          )

          put api_v1_sessions_new_password_url,
              params: {
                token: 'valid_token',
                password: 'short',
                password_confirmation: 'mismatch'
              },
              headers: @headers,
              as: :json

          assert_response :unprocessable_entity
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['error']
        end
      end
    end
  end
end
