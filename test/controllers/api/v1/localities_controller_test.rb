# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class LocalitiesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @locality = localities(:locality_paris)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get show' do
        get api_v1_locality_url(@locality), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @locality.id, json_response['id']
      end

      test 'should get geo_json' do
        get geo_json_api_v1_localities_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
      end

      test 'should get climbers' do
        get climbers_api_v1_locality_url(@locality), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should filter climbers by level' do
        get climbers_api_v1_locality_url(@locality), 
            params: { level: '5a' },
            headers: @user_headers
        assert_response :success
      end

      test 'should filter climbers by partner_search' do
        get climbers_api_v1_locality_url(@locality), 
            params: { partner_search: 'true' },
            headers: @user_headers
        assert_response :success
      end

      test 'should filter climbers by climbing_type' do
        get climbers_api_v1_locality_url(@locality), 
            params: { climbing_type: 'sport_climbing' },
            headers: @user_headers
        assert_response :success
      end
    end
  end
end
