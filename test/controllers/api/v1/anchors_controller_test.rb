# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AnchorsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @api_headers = api_headers
      end

      test 'should get index' do
        get api_v1_anchors_url, headers: @api_headers, as: :json
        assert_response :success
        
        json_response = JSON.parse(response.body)
        assert_equal Anchor::LIST, json_response
      end
    end
  end
end
