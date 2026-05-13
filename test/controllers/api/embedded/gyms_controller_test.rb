# frozen_string_literal: true

require 'test_helper'

module Api
  module Embedded
    class GymsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym.update_column(:assigned_at, Time.current)
        @headers = api_access_token_headers
      end

      test 'should get gym details' do
        get api_embedded_gym_url(@gym), headers: @headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal @gym.name, json_response['data']['attributes']['name']
      end

      test 'should return 404 if gym has no assigned_at' do
        @gym.update_column(:assigned_at, nil)
        get api_embedded_gym_url(@gym), headers: @headers, as: :json
        assert_response :not_found
      end

      test 'should return 404 for non-existent gym' do
        get api_embedded_gym_url(id: 0), headers: @headers, as: :json
        assert_response :not_found
      end
    end
  end
end
