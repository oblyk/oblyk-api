# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module LogBooks
      class OutdoorsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:normal_user)
          @crag = crags(:rocher_des_aures)
          @api_headers = api_headers(user: :normal_user)
        end

        test 'should get stats' do
          get stats_api_v1_log_books_outdoors_url(stats_list: %w[figures climb_types_chart grades_chart years_chart months_chart evolution_chart]),
              headers: @api_headers,
              as: :json
          assert_response :success
        end

        test 'should get ascended crag routes' do
          get ascended_crag_routes_api_v1_log_books_outdoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get daily ascents' do
          get daily_ascents_api_v1_log_books_outdoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get ascents of crag' do
          get ascents_of_crag_api_v1_log_books_outdoors_url(crag_id: @crag.id),
              headers: @api_headers,
              as: :json
          assert_response :success
        end

        test 'should fail if not authenticated' do
          get daily_ascents_api_v1_log_books_outdoors_url, as: :json
          assert_response :forbidden
        end
      end
    end
  end
end
