# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ClimbingSessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @session = climbing_sessions(:session_one)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_climbing_sessions_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response['sessions']
      end

      test 'should get index with gym_ids' do
        gym = gyms(:my_gym)
        get api_v1_climbing_sessions_url, params: { gym_ids: [gym.id] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response['sessions']
      end

      test 'should get index with crag_ids' do
        crag = crags(:rocher_des_aures)
        get api_v1_climbing_sessions_url, params: { crag_ids: [crag.id] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response['sessions']
      end

      test 'should get index with only_crag' do
        get api_v1_climbing_sessions_url, params: { only_crag: 'true' }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response['sessions']
        assert json_response['sessions'].all? { |s| s['crags'].present? }
      end

      test 'should get index with only_gym' do
        get api_v1_climbing_sessions_url, params: { only_gym: 'true' }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response['sessions']
        assert json_response['sessions'].all? { |s| s['gyms'].present? }
      end

      test 'should get index with user_uuid' do
        get api_v1_climbing_sessions_url, params: { user_uuid: @other_user.uuid }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response['sessions']
      end

      test 'should get subscribes_climbing_sessions' do
        get subscribes_climbing_sessions_api_v1_climbing_sessions_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response['sessions']
      end

      test 'should get friends_climbing_sessions' do
        get friends_climbing_sessions_api_v1_climbing_sessions_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_not_empty json_response
        assert_equal @other_user.uuid, json_response.first['user_uuid']
      end

      test 'should show climbing_session' do
        get api_v1_climbing_session_url(@session.session_date), headers: @user_headers
        assert_response :success
      end

      test 'should show climbing_session of followed user' do
        other_session = climbing_sessions(:session_other_user)
        get api_v1_climbing_session_url(other_session.session_date), params: { user_id: @other_user.id }, headers: @user_headers
        assert_response :success
      end

      test 'should return 404 for non-existent session' do
        get api_v1_climbing_session_url('2000-01-01'), headers: @user_headers
        assert_response :not_found
      end

      test 'should update climbing_session' do
        put api_v1_climbing_session_url(@session.session_date),
            params: { climbing_session: { description: 'Nouvelle description' } },
            headers: @user_headers,
            as: :json
        assert_response :no_content
        @session.reload
        assert_equal 'Nouvelle description', @session.description
      end
    end
  end
end
