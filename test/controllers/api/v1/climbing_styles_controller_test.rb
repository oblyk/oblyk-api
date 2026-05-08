# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ClimbingStylesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @api_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_climbing_styles_url, headers: @api_headers, as: :json
        assert_response :success

        json_response = JSON.parse(response.body)
        assert_equal ClimbingStyle::STYLE_LIST.sort, json_response.sort
      end
    end
  end
end
