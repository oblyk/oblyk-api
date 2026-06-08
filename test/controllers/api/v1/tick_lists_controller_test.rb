# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class TickListsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @auth_headers = api_headers(user: :normal_user)
        @crag_route = crag_routes(:petit_ange)
        @tick_list_one = tick_lists(:one)
      end

      test 'should get index' do
        get api_v1_tick_lists_url, headers: @auth_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal @user.tick_lists.count, json_response.count
      end

      test 'should create tick_list' do
        assert_difference('TickList.count', 1) do
          post api_v1_tick_lists_url,
               params: { crag_route_id: @crag_route.id },
               headers: @auth_headers,
               as: :json
        end
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_includes json_response, @crag_route.id
      end

      test 'should destroy tick_list' do
        assert_difference('TickList.count', -1) do
          delete api_v1_tick_lists_url,
                 params: { crag_route_id: @tick_list_one.crag_route_id },
                 headers: @auth_headers,
                 as: :json
        end
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_includes json_response, @tick_list_one.crag_route_id
      end

      test 'should not access without session' do
        get api_v1_tick_lists_url, as: :json
        assert_response :forbidden
      end

      test 'should not access without token' do
        get api_v1_tick_lists_url,
            headers: api_access_token_headers,
            as: :json
        assert_response :unauthorized
      end
    end
  end
end
