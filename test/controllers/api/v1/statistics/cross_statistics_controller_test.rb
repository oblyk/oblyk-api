# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Statistics
      class CrossStatisticsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @gym = gyms(:my_gym)
          @user = users(:gym_route_setter_user) # gym_route_setter_user is gym_administrator for my_gym
          @headers = api_headers(user: :gym_route_setter_user)
        end

        test 'should get index' do
          get api_v1_gym_statistics_cross_statistics_url(gym_id: @gym.id, by: 'sector', number_of: 'grade'),
              headers: @headers,
              as: :json

          assert_response :success
          json_response = JSON.parse(response.body)
          assert_not_nil json_response['results']
          assert_not_nil json_response['column_headers']
          assert_not_nil json_response['params']
        end

        test 'should get index with by and number_of params' do
          get api_v1_gym_statistics_cross_statistics_url(gym_id: @gym.id, by: 'grade', number_of: 'level'),
              headers: @headers,
              as: :json

          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 'grade', json_response['params']['by']
          assert_equal 'level', json_response['params']['number_of']
        end

        test 'should get index with gym_space_ids' do
          space = gym_spaces(:my_gym_boulder_space)
          get api_v1_gym_statistics_cross_statistics_url(gym_id: @gym.id, by: 'sector', number_of: 'grade', gym_space_ids: [space.id]),
              headers: @headers,
              as: :json

          assert_response :success
        end
      end
    end
  end
end
