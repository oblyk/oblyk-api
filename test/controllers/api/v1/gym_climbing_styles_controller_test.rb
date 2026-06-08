# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymClimbingStylesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @user = users(:gym_route_setter_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @climbing_style = gym_climbing_styles(:one)
      end

      test 'should get index' do
        get api_v1_gym_gym_climbing_styles_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_includes json_response.keys, 'bouldering'
      end

      test 'should create gym climbing style' do
        assert_difference('GymClimbingStyle.count', 1) do
          post api_v1_gym_gym_climbing_styles_url(gym_id: @gym.id),
               params: {
                 gym_climbing_style: {
                   style: 'resistance',
                   climbing_type: 'bouldering',
                   color: '#ffffff'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should reactivate and update existing climbing style on create' do
        @climbing_style.update(deactivated_at: Time.current)
        assert_no_difference('GymClimbingStyle.count') do
          post api_v1_gym_gym_climbing_styles_url(gym_id: @gym.id),
               params: {
                 gym_climbing_style: {
                   style: @climbing_style.style,
                   climbing_type: @climbing_style.climbing_type,
                   color: '#000000'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
        @climbing_style.reload
        assert_nil @climbing_style.deactivated_at
        assert_equal '#000000', @climbing_style.color
      end

      test 'should deactivate gym climbing style' do
        put deactivate_api_v1_gym_gym_climbing_styles_url(gym_id: @gym.id),
            params: {
              gym_climbing_style: {
                style: @climbing_style.style,
                climbing_type: @climbing_style.climbing_type
              }
            },
            headers: @user_headers, as: :json
        assert_response :no_content
        @climbing_style.reload
        assert_not_nil @climbing_style.deactivated_at
      end

      test 'should fail to create if not authorized' do
        other_user_headers = api_headers(user: :lulu)
        post api_v1_gym_gym_climbing_styles_url(gym_id: @gym.id),
             params: {
               gym_climbing_style: {
                 style: 'resistance',
                 climbing_type: 'bouldering',
                 color: '#ffffff'
               }
             },
             headers: other_user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
