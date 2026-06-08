# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CommonsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @public_headers = api_access_token_headers
      end

      test 'should get figures' do
        get api_v1_figures_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('all')
        assert json_response.key?('latest')
        assert json_response['all'].key?('crags_count')
      end

      test 'should get micro_stats' do
        get '/api/v1/micro_stats', params: { figures: %w[climbers_count gyms_count] }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('climbers_count')
        assert json_response.key?('gyms_count')
        assert_not json_response.key?('crags_count')
      end

      test 'should get last_added' do
        get api_v1_last_added_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('crags')
        assert json_response.key?('gyms')
        assert json_response.key?('crag_routes')
      end

      test 'should get active_gyms' do
        get api_v1_active_gyms_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get last_contributions' do
        get api_v1_last_contributions_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('data')
      end
    end
  end
end
