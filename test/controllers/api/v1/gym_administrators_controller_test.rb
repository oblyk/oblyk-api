# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymAdministratorsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @admin = users(:super_admin_user)
        @admin_headers = api_headers(user: :super_admin_user)
        @user = users(:gym_route_setter_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @gym_admin = gym_administrators(:gym_administrator_one)
      end

      test 'should get index' do
        get api_v1_gym_gym_administrators_url(gym_id: @gym.id), headers: @admin_headers
        assert_response :success
      end

      test 'should show gym administrator' do
        get api_v1_gym_gym_administrator_url(gym_id: @gym.id, id: @gym_admin.id), headers: @admin_headers
        assert_response :success
      end

      test 'should create gym administrator' do
        assert_difference('GymAdministrator.count', 1) do
          post api_v1_gym_gym_administrators_url(gym_id: @gym.id),
               params: {
                 gym_administrator: {
                   requested_email: 'new_admin@test.com',
                   roles: ['manage_gym']
                 }
               },
               headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym administrator' do
        patch api_v1_gym_gym_administrator_url(gym_id: @gym.id, id: @gym_admin.id),
              params: {
                gym_administrator: {
                  roles: %w[manage_gym manage_space]
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @gym_admin.reload
        assert_includes @gym_admin.roles, 'manage_space'
      end

      test 'should destroy gym administrator' do
        assert_difference('GymAdministrator.count', -1) do
          delete api_v1_gym_gym_administrator_url(gym_id: @gym.id, id: @gym_admin.id),
                 headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update feed last read' do
        put update_feed_last_read_api_v1_gym_gym_administrators_url(gym_id: @gym.id),
            params: { feed_type: 'comment' },
            headers: @user_headers, as: :json
        assert_response :no_content
      end

      test 'should get new in feeds' do
        get new_in_feeds_api_v1_gym_gym_administrators_url(gym_id: @gym.id),
            params: { feeds: %w[comment video] },
            headers: @user_headers
        assert_response :success
      end

      test 'should not create gym administrator if not authorized' do
        post api_v1_gym_gym_administrators_url(gym_id: @gym.id),
             params: {
               gym_administrator: {
                 requested_email: 'fail@test.com',
                 roles: ['manage_gym']
               }
             },
             headers: @user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
