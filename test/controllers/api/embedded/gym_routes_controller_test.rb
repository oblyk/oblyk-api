# frozen_string_literal: true

require 'test_helper'

module Api
  module Embedded
    class GymRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @gym_sector = gym_sectors(:my_gym_sector)
        @gym_route = gym_routes(:gym_route_one)
        @headers = api_access_token_headers
      end

      test 'should get index' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id), headers: @headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response['data']
      end

      test 'should filter index by gym_space_id' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id), headers: @headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response['data']
      end

      test 'should filter index by gym_sector_id' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id, gym_sector_id: @gym_sector.id), headers: @headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_not_empty json_response['data']
      end

      test 'should sort index by grade' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id, sort: 'grade'), headers: @headers, as: :json
        assert_response :success
      end

      test 'should sort index by color' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id, sort: 'color'), headers: @headers, as: :json
        assert_response :success
      end

      test 'should sort index by sector' do
        get api_embedded_gym_gym_routes_url(gym_id: @gym.id, sort: 'sector'), headers: @headers, as: :json
        assert_response :success
      end

      test 'should get show' do
        get api_embedded_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal @gym_route.id.to_s, json_response['data']['id']
      end

      test 'should return 404 for non-existent gym_route' do
        get api_embedded_gym_gym_route_url(gym_id: @gym.id, id: 0), headers: @headers, as: :json
        assert_response :not_found
      end
    end
  end
end
