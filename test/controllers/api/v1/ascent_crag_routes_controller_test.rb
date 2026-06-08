# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AscentCragRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @ascent_crag_route = ascent_crag_routes(:crag_ascent_one)
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @crag_route = crag_routes(:route_one)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_ascent_crag_routes_url, headers: @user_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get index with crag_route_id' do
        get api_v1_ascent_crag_routes_url, params: {
          crag_route_id: @crag_route.id,
          ascent_status: 'sent',
          roping_status: 'lead_climb',
          released_at: '2024-06-06'
        }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should export ascents' do
        get export_api_v1_ascent_crag_routes_url, params: { type: 'ascents' }, headers: @user_headers
        assert_response :success
        assert_equal 'text/csv', response.content_type
      end

      test 'should show ascent_crag_route' do
        get api_v1_ascent_crag_route_url(@ascent_crag_route), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @ascent_crag_route.id, json_response['id']
      end

      test 'should create ascent_crag_route' do
        assert_difference('AscentCragRoute.count') do
          post api_v1_ascent_crag_routes_url,
               params: {
                 ascent_crag_route: {
                   crag_route_id: @crag_route.id,
                   ascent_status: 'sent',
                   roping_status: 'lead_climb',
                   released_at: '2024-06-06',
                   selected_sections: [0]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :created
      end

      test 'should update ascent_crag_route' do
        put api_v1_ascent_crag_route_url(@ascent_crag_route),
            params: {
              ascent_crag_route: {
                note: 5,
                selected_sections: [0]
              }
            },
            headers: @user_headers,
            as: :json
        assert_response :created
        @ascent_crag_route.reload
        assert_equal 5, @ascent_crag_route.note
      end

      test 'should not update ascent_crag_route of other user' do
        put api_v1_ascent_crag_route_url(@ascent_crag_route),
            params: { ascent_crag_route: { note: 4 } },
            headers: @other_user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy ascent_crag_route' do
        assert_difference('AscentCragRoute.count', -1) do
          delete api_v1_ascent_crag_route_url(@ascent_crag_route), headers: @user_headers, as: :json
        end
        assert_response :created
      end

      test 'should add ascent user' do
        post add_ascent_user_api_v1_ascent_crag_route_url(@ascent_crag_route),
             params: { ascent_user: { user_id: @other_user.id } },
             headers: @user_headers,
             as: :json
        assert_response :no_content
      end

      test 'should remove ascent user' do
        AscentUser.create!(user: @other_user, ascent: @ascent_crag_route)

        delete remove_ascent_user_api_v1_ascent_crag_route_url(@ascent_crag_route),
               params: { ascent_user: { user_id: @other_user.id } },
               headers: @user_headers,
               as: :json
        assert_response :no_content
      end
    end
  end
end
