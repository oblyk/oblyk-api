# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class LikesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:other_user)
        @gym_route = gym_routes(:gym_route_one)
        @like = likes(:gym_route_like)

        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :other_user)
      end

      test 'should get index' do
        get api_v1_likes_url,
            params: { likeable_type: 'GymRoute', likeable_id: @gym_route.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should create like' do
        new_route = gym_routes(:gym_route_two)
        assert_difference('Like.count', 1) do
          post api_v1_likes_url,
               params: {
                 like: {
                   likeable_type: 'GymRoute',
                   likeable_id: new_route.id
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should destroy like' do
        assert_difference('Like.count', -1) do
          delete "/api/v1/likes/GymRoute/#{@gym_route.id}",
                 headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy like of another user' do
        assert_no_difference('Like.count') do
          delete "/api/v1/likes/GymRoute/#{@gym_route.id}",
                 headers: @other_user_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
