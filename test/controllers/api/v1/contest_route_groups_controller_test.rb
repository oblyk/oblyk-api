# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestRouteGroupsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @contest_stage = contest_stages(:stage_1)
        @contest_stage_step = contest_stage_steps(:step_1_stage_1)
        @contest_route_group = contest_route_groups(:route_group_1)
        @user = users(:normal_user)
        @admin = users(:super_admin_user)
        
        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_groups_url(
          @gym, @contest, @contest_stage, @contest_stage_step
        ), headers: @public_headers
        assert_response :success
      end

      test 'should show contest_route_group' do
        get api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_group_url(
          @gym, @contest, @contest_stage, @contest_stage_step, @contest_route_group
        ), headers: @public_headers
        assert_response :success
      end

      test 'should create contest_route_group' do
        assert_difference('ContestRouteGroup.count') do
          post api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_groups_url(
            @gym, @contest, @contest_stage, @contest_stage_step
          ), params: {
            contest_route_group: {
              genre_type: 'female',
              waveable: false,
              contest_category_ids: [contest_categories(:category_senior).id]
            }
          }, headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should create contest_route_group with routes' do
        assert_difference('ContestRoute.count', 3) do
          post api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_groups_url(
            @gym, @contest, @contest_stage, @contest_stage_step
          ), params: {
            contest_route_group: {
              genre_type: 'male',
              waveable: false,
              number_of_routes: 3,
              contest_category_ids: [contest_categories(:category_custom).id]
            }
          }, headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update contest_route_group' do
        put api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_group_url(
          @gym, @contest, @contest_stage, @contest_stage_step, @contest_route_group
        ), params: {
          contest_route_group: {
            genre_type: 'male'
          }
        }, headers: @admin_headers, as: :json
        assert_response :success
        @contest_route_group.reload
        assert_equal 'male', @contest_route_group.genre_type
      end

      test 'should add route to contest_route_group' do
        assert_difference('ContestRoute.count') do
          post add_route_api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_group_url(
            @gym, @contest, @contest_stage, @contest_stage_step, @contest_route_group
          ), headers: @admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should destroy contest_route_group' do
        assert_difference('ContestRouteGroup.count', -1) do
          delete api_v1_gym_contest_contest_stage_contest_stage_step_contest_route_group_url(
            @gym, @contest, @contest_stage, @contest_stage_step, @contest_route_group
          ), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
