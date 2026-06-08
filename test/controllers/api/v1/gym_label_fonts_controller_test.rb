# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymLabelFontsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_gym_label_fonts_url, headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response
        assert_includes json_response.keys, 'lato'
      end
    end
  end
end
