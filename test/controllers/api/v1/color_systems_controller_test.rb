# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ColorSystemsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @color_system = color_systems(:system_1)
        @user = users(:normal_user)
        @gym = gyms(:my_gym)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_color_systems_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert json_response.length >= 2
      end

      test 'should get index with gym_id' do
        get api_v1_color_systems_url, params: { gym_id: @gym.id }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show color_system' do
        get api_v1_color_system_url(@color_system), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @color_system.id, json_response['id']
        assert_equal @color_system.colors_mark, json_response['colors_mark']
      end

      test 'should create color_system' do
        assert_difference('ColorSystem.count', 1) do
          post api_v1_color_systems_url,
               params: {
                 color_system: {
                   colors: ['#111111', '#222222']
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_equal '#111111#222222', json_response['colors_mark']
      end

      test 'should return existing color_system if colors already exist' do
        assert_no_difference('ColorSystem.count') do
          post api_v1_color_systems_url,
               params: {
                 color_system: {
                   colors: ['#FF0000', '#00FF00', '#0000FF']
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_equal @color_system.id, json_response['id']
      end

      test 'should not create color_system if not authenticated' do
        assert_no_difference('ColorSystem.count') do
          post api_v1_color_systems_url,
               params: {
                 color_system: {
                   colors: ['#333333']
                 }
               },
               headers: api_access_token_headers,
               as: :json
        end
        assert_response :unauthorized
      end
    end
  end
end
