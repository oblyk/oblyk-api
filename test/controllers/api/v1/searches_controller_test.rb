# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class SearchesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @api_headers = api_headers
      end

      test 'should get search results for index' do
        get api_v1_search_url(query: 'orpierre'), headers: @api_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_includes json_response.keys, 'crags'
        assert_includes json_response.keys, 'gyms'
        assert_includes json_response.keys, 'guide_book_papers'
        assert_includes json_response.keys, 'users'
        assert_includes json_response.keys, 'crag_routes'
        assert_includes json_response.keys, 'words'
        assert_includes json_response.keys, 'areas'
      end

      test 'should find results when search index is populated' do
        ENV['SEARCH_INGESTABLE'] = 'true'
        Crag.find_each(&:refresh_search_index)
        Gym.find_each(&:refresh_search_index)

        get api_v1_search_url(query: 'orpierre'), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response['crags']

        get api_v1_search_all_url(query: 'orpierre'), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response['results']

        ENV['SEARCH_INGESTABLE'] = 'false'
      end

      test 'should return empty if no query in index' do
        get api_v1_search_url, headers: @api_headers, as: :json
        assert_response :no_content
      end

      test 'should get search all results' do
        get api_v1_search_all_url(query: 'orpierre'), headers: @api_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal 'orpierre', json_response['query']
        assert_kind_of Array, json_response['results']
      end

      test 'should get search around results' do
        get api_v1_search_around_url(latitude: 44.3, longitude: 5.7), headers: @api_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_not_empty json_response
        assert_equal 'Crag', json_response.first['type']
      end
    end
  end
end
