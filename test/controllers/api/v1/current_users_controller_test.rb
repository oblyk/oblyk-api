# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CurrentUsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should show current user' do
        get '/api/v1/current_users', headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @user.id, json_response['id']
      end

      test 'should get favorite crags' do
        get favorite_crags_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get favorite gyms' do
        get favorite_gyms_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get subscribes' do
        get subscribes_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get library' do
        get library_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get likes' do
        get likes_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get library figures' do
        get library_figures_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should update current user' do
        put '/api/v1/current_users',
            params: { user: { first_name: 'NewName' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @user.reload
        assert_equal 'NewName', @user.first_name
      end

      test 'should update password' do
        put update_password_api_v1_current_users_url,
            params: { user: { password: 'NewPassword123', password_confirmation: 'NewPassword123' } },
            headers: @user_headers,
            as: :json
        assert_response :success
      end

      test 'should upload avatar' do
        dummy_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post avatar_api_v1_current_users_url,
             params: { user: { avatar: dummy_file } },
             headers: @user_headers
        assert_response :success
      end

      test 'should upload banner' do
        dummy_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post banner_api_v1_current_users_url,
             params: { user: { banner: dummy_file } },
             headers: @user_headers
        assert_response :success
      end

      test 'should get followers' do
        get followers_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get waiting followers' do
        get waiting_followers_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should accept follower' do
        other_user = users(:other_user)
        private_user = users(:private_user)
        follow = Follow.create!(
          user: other_user,
          followable: private_user,
          accepted_at: nil
        )

        post accept_followers_api_v1_current_users_url,
             params: { user_id: other_user.id },
             headers: api_headers(user: :private_user),
             as: :json
        assert_response :no_content
        follow.reload
        assert_not_nil follow.accepted_at
      end

      test 'should reject follower' do
        other_user = users(:other_user)
        private_user = users(:private_user)
        follow = Follow.create!(
          user: other_user,
          followable: private_user,
          accepted_at: nil
        )

        delete reject_followers_api_v1_current_users_url,
               params: { user_id: other_user.id },
               headers: api_headers(user: :private_user),
               as: :json
        assert_response :no_content
        assert_not Follow.exists?(follow.id)
      end

      test 'should get upcoming contests' do
        get upcoming_contests_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get projects' do
        get projects_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get tick lists' do
        get tick_lists_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get ascended crags geo json' do
        get ascended_crags_geo_json_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should get subscribes ascents' do
        get subscribes_ascents_api_v1_current_users_url, headers: @user_headers
        assert_response :success
      end

      test 'should destroy current user' do
        delete '/api/v1/current_users', headers: @user_headers
        assert_response :no_content
        @user.reload
        assert_not_nil @user.deleted_at
      end
    end
  end
end
