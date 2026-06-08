# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestTeamsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_ongoing)
        @team = contest_teams(:team_1)

        @user = users(:gym_route_setter_user)
        @admin = users(:super_admin_user)

        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :gym_route_setter_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_teams_url(@gym, @contest), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show contest_team' do
        get api_v1_gym_contest_contest_team_url(@gym, @contest, @team), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @team.name, json_response['name']
      end

      test 'should create contest_team' do
        assert_difference('ContestTeam.count') do
          post api_v1_gym_contest_contest_teams_url(@gym, @contest),
               params: {
                 contest_team: {
                   name: 'New Team'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end


      test 'should update contest_team' do
        put api_v1_gym_contest_contest_team_url(@gym, @contest, @team),
            params: { contest_team: { name: 'Updated Team Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @team.reload
        assert_equal 'Updated Team Name', @team.name
      end

      test 'should not update contest_team for non admin' do
        put api_v1_gym_contest_contest_team_url(@gym, @contest, @team),
            params: { contest_team: { name: 'Unauthorized Update' } },
            headers: @user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy contest_team' do
        assert_difference('ContestTeam.count', -1) do
          delete api_v1_gym_contest_contest_team_url(@gym, @contest, @team), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy contest_team for non admin' do
        assert_no_difference('ContestTeam.count') do
          delete api_v1_gym_contest_contest_team_url(@gym, @contest, @team), headers: @user_headers, as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
