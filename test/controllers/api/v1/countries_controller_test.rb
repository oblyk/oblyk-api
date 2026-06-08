# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CountriesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @country = countries(:france)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_countries_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal Country.count, json_response.size
      end

      test 'should show country' do
        get api_v1_country_url(@country.code_country), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @country.name, json_response['name']
        assert_equal @country.code_country, json_response['code_country']
      end

      test 'should get route figures' do
        get route_figures_api_v1_country_url(@country.code_country), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('route_count')
        assert json_response.key?('climbing_types')
      end

      test 'should get geo json' do
        get geo_json_api_v1_country_url(@country.code_country), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert json_response.key?('features')
      end
    end
  end
end
