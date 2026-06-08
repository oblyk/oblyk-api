# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymRolesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_gym_roles_url, headers: @user_headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json
        assert_includes json, 'manage_gym'
      end
    end
  end
end
