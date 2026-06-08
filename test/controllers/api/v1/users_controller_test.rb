# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @user.update_columns(public_profile: true, public_outdoor_ascents: true, public_indoor_ascents: true)
        @private_user = users(:other_user)
        @api_headers = api_headers(user: :normal_user)
      end

      test 'should get show' do
        get api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should not get show for private profile if not logged in' do
        get api_v1_user_url(@private_user.slug_name), headers: api_access_token_headers, as: :json
        assert_response :forbidden
      end

      test 'should get show for private profile if logged in' do
        get api_v1_user_url(@private_user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get search when logged in' do
        get search_api_v1_users_url(query: 'Jean'), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should not get search when not logged in' do
        get search_api_v1_users_url(query: 'Jean'), headers: api_access_token_headers, as: :json
        assert_response :unauthorized
      end

      test 'should get subscribes' do
        get subscribes_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get followers' do
        get followers_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get photos' do
        get photos_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get videos' do
        get videos_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get contribution' do
        get contribution_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get stats' do
        get stats_api_v1_user_url(@user.slug_name, stats_list: ['figures']), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get ascended_crag_routes' do
        get ascended_crag_routes_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get indoor_figures' do
        get indoor_figures_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get indoor_climb_types_chart' do
        get indoor_climb_types_chart_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get indoor_grade_chart' do
        get indoor_grade_chart_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get indoor_by_level_chart' do
        get indoor_by_level_chart_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get localities' do
        get localities_api_v1_user_url(@user.slug_name), headers: @api_headers, as: :json
        assert_response :success
      end
    end
  end
end
