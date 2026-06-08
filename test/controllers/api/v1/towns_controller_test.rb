# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class TownsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @town = towns(:valence)
        @headers = api_access_token_headers
      end

      test 'should search towns' do
        get search_api_v1_towns_url(query: 'Valence'), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert json_response.any? { |town| town['name'] == 'Valence' }
      end

      test 'should get towns by geo search' do
        get geo_search_api_v1_towns_url(latitude: 44.93, longitude: 4.89), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show town' do
        get api_v1_town_url(@town.slug_name), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @town.name, json_response['name']
      end

      test 'should return 404 for non-existent town' do
        get api_v1_town_url('non-existent-town'), headers: @headers
        assert_response :not_found
      end

      test 'should get geo_json' do
        get geo_json_api_v1_town_url(@town.slug_name), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert_kind_of Array, json_response['features']
      end

      test 'should get geo_json with parameters' do
        get geo_json_api_v1_town_url(@town.slug_name),
            params: { minimalistic: 'true', dist: 20 },
            headers: @headers
        assert_response :success
      end
    end
  end
end
