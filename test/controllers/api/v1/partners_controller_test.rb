# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PartnersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @user.update_columns(
          partner_search: true,
          last_activity_at: DateTime.current,
          partner_search_activated_at: DateTime.current
        )
        @headers = api_headers
      end

      test 'should get figures' do
        get api_v1_partners_figures_url, headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_includes json_response.keys, 'count_global'
        assert_includes json_response.keys, 'count_last_week'
        assert_operator json_response['count_global'], :>=, 0
      end

      test 'should get partners around' do
        get api_v1_partners_partners_around_url, params: {
          latitude: 48.8566,
          longitude: 2.3522
        }, headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_includes json_response.map { |u| u['id'] }, @user.id
      end
    end
  end
end
