# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    module LogBooks
      class IndoorsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:normal_user)
          @api_headers = api_headers(user: :normal_user)
        end

        test 'should get figures' do
          get figures_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get climb types chart' do
          get climb_types_chart_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get years chart' do
          get years_chart_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get months chart' do
          get months_chart_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get grades chart' do
          get grades_chart_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get by levels chart' do
          get by_levels_chart_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should get simple stats by gyms' do
          get simple_stats_by_gyms_api_v1_log_books_indoors_url, headers: @api_headers, as: :json
          assert_response :success
        end

        test 'should fail if not authenticated' do
          get figures_api_v1_log_books_indoors_url, as: :json
          assert_response :forbidden
        end
      end
    end
  end
end
