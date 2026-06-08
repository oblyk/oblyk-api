# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AscentGymRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @ascent_gym_route = ascent_gym_routes(:gym_ascent_one)
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @gym = gyms(:my_gym)
        @gym_route = gym_routes(:gym_route_one)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_ascent_gym_routes_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get index with filters' do
        get api_v1_ascent_gym_routes_url,
            params: {
              gym_id: @gym.id,
              ascent_status: ['sent'],
              climbing_types: ['bouldering']
            },
            headers: @user_headers
        assert_response :success
      end

      test 'should get gym_routes_infos_in_logbook' do
        get gym_routes_infos_in_logbook_api_v1_ascent_gym_routes_url,
            params: { route_ids: [@gym_route.id] },
            headers: @user_headers
        assert_response :success
      end

      test 'should show ascent_gym_route' do
        get api_v1_ascent_gym_route_url(@ascent_gym_route), headers: @user_headers
        assert_response :success
      end

      test 'should create ascent_gym_route' do
        assert_difference('AscentGymRoute.count') do
          post api_v1_ascent_gym_routes_url,
               params: {
                 ascent_gym_route: {
                   gym_route_id: @gym_route.id,
                   ascent_status: 'sent',
                   released_at: '2024-06-06',
                   climbing_type: 'bouldering',
                   selected_sections: [0]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :created
      end

      test 'should create_bulk ascent_gym_routes' do
        assert_difference('AscentGymRoute.count', 1) do
          post create_bulk_api_v1_ascent_gym_routes_url,
               params: {
                 gym_ascents: {
                   gym_id: @gym.id,
                   released_at: '2024-06-06',
                   climbing_type: 'bouldering',
                   ascents_by: 'grade',
                   ascents: [
                     {
                       height: 4,
                       grade: '6a',
                       quantity: 1,
                       ascent_status: 'sent'
                     }
                   ]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :created
      end

      test 'should add_bulk ascent_gym_routes' do
        assert_difference('AscentGymRoute.count', 1) do
          post add_bulk_api_v1_ascent_gym_routes_url,
               params: {
                 gym_ascents: [
                   {
                     gym_route_id: @gym_route.id,
                     ascent_status: 'sent',
                     released_at: '2024-06-06',
                     roping_status: 'lead_climb'
                   }
                 ]
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :created
      end

      test 'should update ascent_gym_route' do
        put api_v1_ascent_gym_route_url(@ascent_gym_route),
            params: { ascent_gym_route: { note: 5 } },
            headers: @user_headers,
            as: :json
        assert_response :created
      end

      test 'should not update ascent_gym_route of other user' do
        put api_v1_ascent_gym_route_url(@ascent_gym_route),
            params: { ascent_gym_route: { note: 4 } },
            headers: @other_user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy ascent_gym_route' do
        assert_difference('AscentGymRoute.count', -1) do
          delete api_v1_ascent_gym_route_url(@ascent_gym_route), headers: @user_headers, as: :json
        end
        assert_response :created
      end

      test 'should get points' do
        get points_api_v1_ascent_gym_routes_url,
            params: {
              user_uuid: @user.uuid,
              gym_id: @gym.id,
              climbing_type: 'bouldering'
            },
            headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should create ascent_gym_route with comment' do
        assert_difference('AscentGymRoute.count', 1) do
          assert_difference('Comment.count', 1) do
            post api_v1_ascent_gym_routes_url,
                 params: {
                   ascent_gym_route: {
                     gym_route_id: @gym_route.id,
                     ascent_status: 'sent',
                     released_at: '2024-06-06',
                     climbing_type: 'bouldering',
                     selected_sections: [0],
                     ascent_comment: { body: 'Un super commentaire' }
                   }
                 },
                 headers: @user_headers,
                 as: :json
          end
        end
        assert_response :created
      end

      test 'should not create ascent_gym_route with invalid params' do
        assert_no_difference('AscentGymRoute.count') do
          post api_v1_ascent_gym_routes_url,
               params: {
                 ascent_gym_route: {
                   gym_route_id: @gym_route.id,
                   ascent_status: 'invalid_status'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :unprocessable_entity
      end
    end
  end
end
