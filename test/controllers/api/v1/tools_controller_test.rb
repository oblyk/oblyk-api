# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ToolsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @api_headers = api_access_token_headers
      end

      test 'should get qr_coder' do
        get qr_coder_api_v1_tools_url(message: 'https://oblyk.org'), headers: @api_headers
        assert_response :success
        assert_equal 'image/svg+xml', response.content_type
        assert_match(/<svg/, response.body)
      end

      test 'should get qr_coder with empty message' do
        get qr_coder_api_v1_tools_url, headers: @api_headers
        assert_response :success
        assert_equal 'image/svg+xml', response.content_type
        assert_match(/<svg/, response.body)
      end

      test 'should return forbidden without api access token' do
        get qr_coder_api_v1_tools_url(message: 'https://oblyk.org')
        assert_response :forbidden
      end
    end
  end
end
