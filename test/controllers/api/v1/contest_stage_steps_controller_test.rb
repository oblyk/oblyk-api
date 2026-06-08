# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestStageStepsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @contest_stage = contest_stages(:stage_1)
        @contest_stage_step = contest_stage_steps(:step_1_stage_1)

        @admin = users(:super_admin_user)
        @user = users(:gym_route_setter_user)

        @public_headers = api_access_token_headers
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_stage_contest_stage_steps_url(@gym, @contest, @contest_stage), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get index with routes' do
        get api_v1_gym_contest_contest_stage_contest_stage_steps_url(@gym, @contest, @contest_stage),
            params: { with_routes: 'true' },
            headers: @public_headers
        assert_response :success
      end

      test 'should show contest_stage_step' do
        get api_v1_gym_contest_contest_stage_contest_stage_step_url(@gym, @contest, @contest_stage, @contest_stage_step), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @contest_stage_step.name, json_response['name']
      end

      test 'should create contest_stage_step' do
        assert_difference('ContestStageStep.count') do
          post api_v1_gym_contest_contest_stage_contest_stage_steps_url(@gym, @contest, @contest_stage),
               params: {
                 contest_stage_step: {
                   name: 'Nouveau Step',
                   step_order: 3,
                   ranking_type: 'division',
                   ascents_limit: 10,
                   self_reporting: true,
                   default_participants_for_next_step: 5
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create contest_stage_step for non admin' do
        assert_no_difference('ContestStageStep.count') do
          post api_v1_gym_contest_contest_stage_contest_stage_steps_url(@gym, @contest, @contest_stage),
               params: {
                 contest_stage_step: {
                   name: 'Nouveau Step'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :forbidden
      end

      test 'should update contest_stage_step' do
        put api_v1_gym_contest_contest_stage_contest_stage_step_url(@gym, @contest, @contest_stage, @contest_stage_step),
            params: { contest_stage_step: { name: 'Updated Step Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @contest_stage_step.reload
        assert_equal 'Updated Step Name', @contest_stage_step.name
      end

      test 'should destroy contest_stage_step' do
        assert_difference('ContestStageStep.count', -1) do
          delete api_v1_gym_contest_contest_stage_contest_stage_step_url(@gym, @contest, @contest_stage, @contest_stage_step), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
