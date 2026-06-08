# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestJudgesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @judge = contest_judges(:judge_1)
        @route = contest_routes(:route_3)
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_judges_url(@gym, @contest), headers: @admin_headers, as: :json
        assert_response :success
      end

      test 'should show contest judge' do
        get api_v1_gym_contest_contest_judge_url(@gym, @contest, @judge), headers: @admin_headers, as: :json
        assert_response :success
      end

      test 'should create contest judge' do
        assert_difference('ContestJudge.count') do
          post api_v1_gym_contest_contest_judges_url(@gym, @contest),
               params: {
                 contest_judge: {
                   name: 'New Judge',
                   code: 'NEWCODE'
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update contest judge' do
        put api_v1_gym_contest_contest_judge_url(@gym, @contest, @judge),
            params: {
              contest_judge: {
                name: 'Updated Judge Name'
              }
            },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @judge.reload
        assert_equal 'Updated Judge Name', @judge.name
      end

      test 'should add routes to judge' do
        assert_difference('@judge.contest_routes.count') do
          post add_routes_api_v1_gym_contest_contest_judge_url(@gym, @contest, @judge),
               params: {
                 contest_judge: {
                   contest_route_ids: [@route.id]
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :no_content
      end

      test 'should delete route from judge' do
        route_to_delete = contest_routes(:route_1)
        assert_difference('@judge.contest_routes.count', -1) do
          delete delete_route_api_v1_gym_contest_contest_judge_url(@gym, @contest, @judge),
                 params: {
                   contest_route_id: route_to_delete.id
                 },
                 headers: @admin_headers,
                 as: :json
        end
        assert_response :no_content
      end

      test 'should destroy contest judge' do
        assert_difference('ContestJudge.count', -1) do
          delete api_v1_gym_contest_contest_judge_url(@gym, @contest, @judge), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not allow non-admin to manage judges' do
        other_user_headers = api_headers(user: :other_user)
        get api_v1_gym_contest_contest_judges_url(@gym, @contest), headers: other_user_headers, as: :json
        assert_response :unauthorized
      end
    end
  end
end
