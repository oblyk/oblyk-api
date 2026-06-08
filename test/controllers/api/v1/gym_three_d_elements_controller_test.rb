# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymThreeDElementsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @asset = gym_three_d_assets(:asset_1)
        @element = gym_three_d_elements(:element_1)
        @admin_headers = api_headers(user: :gym_route_setter_user)
        @user_headers = api_headers(user: :lulu)
      end

      test 'should get index' do
        get api_v1_gym_gym_three_d_elements_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should show gym three d element' do
        get api_v1_gym_gym_three_d_element_url(gym_id: @gym.id, id: @element.id), headers: @user_headers
        assert_response :success
      end

      test 'should create gym three d element' do
        assert_difference('GymThreeDElement.count', 1) do
          post api_v1_gym_gym_three_d_elements_url(gym_id: @gym.id),
               params: {
                 gym_three_d_element: {
                   gym_three_d_asset_id: @asset.id,
                   three_d_position: { x: 1, y: 2, z: 3 },
                   three_d_scale: { x: 1, y: 1, z: 1 }
                 }
               },
               headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym three d element' do
        patch api_v1_gym_gym_three_d_element_url(gym_id: @gym.id, id: @element.id),
              params: {
                gym_three_d_element: {
                  message: 'New message'
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @element.reload
        assert_equal 'New message', @element.message
      end

      test 'should destroy gym three d element' do
        assert_difference('GymThreeDElement.count', -1) do
          delete api_v1_gym_gym_three_d_element_url(gym_id: @gym.id, id: @element.id),
                 headers: @admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should not create if not admin' do
        post api_v1_gym_gym_three_d_elements_url(gym_id: @gym.id),
             params: {
               gym_three_d_element: {
                 gym_three_d_asset_id: @asset.id
               }
             },
             headers: @user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
