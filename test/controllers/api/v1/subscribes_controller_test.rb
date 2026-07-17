# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class SubscribesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @subscribe = subscribes(:one)
        @super_admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :normal_user)
        @guest_headers = api_access_token_headers
      end

      test 'should get index if super_admin' do
        get api_v1_subscribes_url, headers: @super_admin_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal Subscribe.count, json_response.size
      end

      test 'should not get index if not super_admin' do
        get api_v1_subscribes_url, headers: @user_headers, as: :json
        assert_response :forbidden
      end

      test 'should create subscribe' do
        assert_difference('Subscribe.count') do
          post api_v1_subscribes_url,
               params: { subscribe: { email: 'new@oblyk.org' } },
               headers: @guest_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should return no_content if already subscribed' do
        assert_no_difference('Subscribe.count') do
          post api_v1_subscribes_url,
               params: { subscribe: { email: @subscribe.email } },
               headers: @guest_headers,
               as: :json
        end
        assert_response :no_content
      end

      test 'should return unprocessable_content if email is invalid' do
        assert_no_difference('Subscribe.count') do
          post api_v1_subscribes_url,
               params: { subscribe: { email: 'invalid-email' } },
               headers: @guest_headers,
               as: :json
        end
        assert_response :unprocessable_content
      end

      test 'should destroy subscribe' do
        assert_difference('Subscribe.count', -1) do
          delete api_v1_subscribes_url,
                 params: { subscribe: { email: @subscribe.email } },
                 headers: @guest_headers,
                 as: :json
        end
        assert_response :no_content
      end

      test 'should return no_content on destroy if email not found' do
        assert_no_difference('Subscribe.count') do
          delete api_v1_subscribes_url,
                 params: { subscribe: { email: 'unknown@oblyk.org' } },
                 headers: @guest_headers,
                 as: :json
        end
        assert_response :no_content
      end
    end
  end
end
