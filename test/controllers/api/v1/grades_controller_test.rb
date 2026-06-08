# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GradesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @headers = api_access_token_headers
      end

      test 'should get grade information' do
        get '/api/v1/public/grade', params: { grade: '6a' }, headers: @headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_equal '6a', json_response['grade']
        assert_equal 31, json_response['value']
        assert_not_nil json_response['color']
      end

      test 'should get grade information for 7b+' do
        get '/api/v1/public/grade', params: { grade: '7b+' }, headers: @headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_equal '7b+', json_response['grade']
        assert_equal 40, json_response['value']
      end

      test 'should return value 0 for unknown grade' do
        get '/api/v1/public/grade', params: { grade: 'unknown' }, headers: @headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response['value']
      end

      test 'should get grade types' do
        get '/api/v1/public/grade-types', headers: @headers
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert json_response.include?('french')
      end
    end
  end
end
