# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class DepartmentsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @country = countries(:france)
        @department = departments(:drome)
        @headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_country_departments_url(country_id: @country.code_country), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @country.departments.count, json_response.size
      end

      test 'should show department' do
        get api_v1_country_department_url(country_id: @country.code_country, id: @department.department_number), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @department.name, json_response['name']
        assert_equal @department.department_number, json_response['department_number']
      end

      test 'should get route_figures' do
        get route_figures_api_v1_country_department_url(country_id: @country.code_country, id: @department.department_number), headers: @headers
        assert_response :success
      end

      test 'should get geo_json' do
        get geo_json_api_v1_country_department_url(country_id: @country.code_country, id: @department.department_number), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert_kind_of Array, json_response['features']
      end

      test 'should get geo_json with parameters' do
        get geo_json_api_v1_country_department_url(country_id: @country.code_country, id: @department.department_number),
            params: { crags: 'true', gyms: 'true', minimalistic: 'true' },
            headers: @headers
        assert_response :success
      end
    end
  end
end
