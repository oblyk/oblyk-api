# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module Statistics
      class GymRouteStatisticsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @gym = gyms(:my_gym)
          @user = users(:normal_user)
          @headers = api_headers(user: :normal_user)
          @filters = { filters: { date: Date.current.to_s } }
        end

        test 'should get figures' do
          post figures_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get routes_by_grades' do
          post routes_by_grades_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get routes_by_levels' do
          post routes_by_levels_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get notes' do
          post notes_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get like_figures' do
          post like_figures_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get difficulty_figures' do
          post difficulty_figures_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get appreciation_figures' do
          post appreciation_figures_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get opening_frequencies' do
          post opening_frequencies_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: @filters,
               headers: @headers,
               as: :json
          assert_response :success
        end

        test 'should get stats with space filters' do
          space = gym_spaces(:my_gym_boulder_space)
          filters = { filters: { date: Date.current.to_s, space_ids: [space.id] } }
          post figures_api_v1_gym_statistics_gym_route_statistics_url(gym_id: @gym.id),
               params: filters,
               headers: @headers,
               as: :json
          assert_response :success
        end
      end
    end
  end
end
