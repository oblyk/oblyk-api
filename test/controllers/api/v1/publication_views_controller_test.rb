# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PublicationViewsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get unread count' do
        get unread_count_api_v1_publication_views_url,
            params: { publishable_type: 'Crag', publishable_id: crags(:rocher_des_aures).id },
            headers: @user_headers
        assert_response :success
      end

      test 'should get unread count for user' do
        get unread_count_api_v1_publication_views_url,
            params: { publishable_type: 'User', publishable_id: users(:super_admin_user).id },
            headers: @user_headers
        assert_response :success
      end

      test 'should get my unread count' do
        get my_unread_count_api_v1_publication_views_url,
            headers: @user_headers
        assert_response :success
      end

      test 'unread count should be 0 if not logged in' do
        # On doit fournir les headers de l'organisation même sans login
        get unread_count_api_v1_publication_views_url,
            params: { publishable_type: 'Crag', publishable_id: crags(:rocher_des_aures).id },
            headers: api_access_token_headers
        assert_response :success
        assert_equal 0, JSON.parse(response.body)
      end
    end
  end
end
