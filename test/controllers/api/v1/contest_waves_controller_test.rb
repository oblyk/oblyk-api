# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestWavesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @contest = contests(:contest_1)
        @wave = contest_waves(:wave_1)

        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_waves_url(@gym, @contest), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show contest wave' do
        get api_v1_gym_contest_contest_wave_url(@gym, @contest, @wave), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @wave.name, json_response['name']
      end

      test 'should create contest wave' do
        assert_difference('ContestWave.count') do
          post api_v1_gym_contest_contest_waves_url(@gym, @contest),
               params: {
                 contest_wave: {
                   name: 'New Wave',
                   capacity: 50
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update contest wave' do
        put api_v1_gym_contest_contest_wave_url(@gym, @contest, @wave),
            params: { contest_wave: { name: 'Updated Wave Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @wave.reload
        assert_equal 'Updated Wave Name', @wave.name
      end

      test 'should destroy contest wave' do
        wave = ContestWave.create!(
          name: 'To Destroy',
          contest: @contest
        )
        assert_difference('ContestWave.count', -1) do
          delete api_v1_gym_contest_contest_wave_url(@gym, @contest, wave), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not create contest wave for non admin' do
        assert_no_difference('ContestWave.count') do
          post api_v1_gym_contest_contest_waves_url(@gym, @contest),
               params: {
                 contest_wave: {
                   name: 'New Wave'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
