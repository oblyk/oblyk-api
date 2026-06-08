# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UserApplicationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @api_headers = api_headers(user: :normal_user)
        @user_application = user_applications(:my_compet_app)
      end

      test 'should get index' do
        get api_v1_user_applications_url, headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
        assert_equal @user_application.id, json_response.first['id']
      end

      test 'should show user application' do
        get api_v1_user_application_url(@user_application), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @user_application.id, json_response['id']
      end

      test 'should destroy user application' do
        assert_difference('UserApplication.count', -1) do
          delete api_v1_user_application_url(@user_application), headers: @api_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should not show another user application' do
        other_user_headers = api_headers(user: :other_user)
        assert_raises(ActiveRecord::RecordNotFound) do
          get api_v1_user_application_url(@user_application), headers: other_user_headers, as: :json
        end
      end
    end
  end
end
