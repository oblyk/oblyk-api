# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestStagesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @contest_stage = contest_stages(:stage_1)
        
        @admin = users(:super_admin_user)
        @user = users(:gym_route_setter_user)
        
        @public_headers = api_access_token_headers
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_stages_url(@gym, @contest), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show contest_stage' do
        get api_v1_gym_contest_contest_stage_url(@gym, @contest, @contest_stage), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @contest_stage.name, json_response['name']
      end

      test 'should create contest_stage' do
        assert_difference('ContestStage.count') do
          post api_v1_gym_contest_contest_stages_url(@gym, @contest),
               params: {
                 contest_stage: {
                   climbing_type: 'bouldering',
                   name: 'Nouveau Stage',
                   description: 'Description du stage',
                   stage_order: 4,
                   default_ranking_type: 'division'
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create contest_stage for non admin' do
        assert_no_difference('ContestStage.count') do
          post api_v1_gym_contest_contest_stages_url(@gym, @contest),
               params: {
                 contest_stage: {
                   climbing_type: 'bouldering',
                   name: 'Nouveau Stage'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :forbidden
      end

      test 'should update contest_stage' do
        put api_v1_gym_contest_contest_stage_url(@gym, @contest, @contest_stage),
            params: { contest_stage: { name: 'Updated Stage Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @contest_stage.reload
        assert_equal 'Updated Stage Name', @contest_stage.name
      end

      test 'should destroy contest_stage' do
        assert_difference('ContestStage.count', -1) do
          delete api_v1_gym_contest_contest_stage_url(@gym, @contest, @contest_stage), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
