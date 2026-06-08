# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CragRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @crag_route = crag_routes(:route_one)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_crag_crag_routes_url(@crag), headers: @user_headers
        assert_response :success
      end

      test 'should show crag_route' do
        get api_v1_crag_route_url(@crag_route), headers: @user_headers
        assert_response :success
      end

      test 'should search crag_routes' do
        get search_api_v1_crag_routes_url, params: { query: 'Route' }, headers: @user_headers
        assert_response :success
      end

      test 'should create crag_route' do
        assert_difference('CragRoute.count') do
          post api_v1_crag_crag_routes_url(@crag),
               params: {
                 crag_route: {
                   name: 'New Route',
                   crag_id: @crag.id,
                   climbing_type: 'sport_climbing',
                   sections: [{ grade: '6a', height: 20 }]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update crag_route' do
        put api_v1_crag_route_url(@crag_route),
            params: { crag_route: { name: 'Updated Route Name' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @crag_route.reload
        assert_equal 'Updated Route Name', @crag_route.name
      end

      test 'should destroy crag_route' do
        assert_difference('CragRoute.count', -1) do
          delete api_v1_crag_route_url(@crag_route), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
