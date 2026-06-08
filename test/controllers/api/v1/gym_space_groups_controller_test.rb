# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymSpaceGroupsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space_group = gym_space_groups(:gym_space_group_1)
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @other_user_headers = api_headers(user: :lulu)
      end

      test 'should get index' do
        get api_v1_gym_gym_space_groups_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should show gym space group' do
        get api_v1_gym_gym_space_group_url(gym_id: @gym.id, id: @gym_space_group.id), headers: @user_headers
        assert_response :success
      end

      test 'should create gym space group' do
        assert_difference('GymSpaceGroup.count', 1) do
          post api_v1_gym_gym_space_groups_url(gym_id: @gym.id),
               params: {
                 gym_space_group: {
                   name: 'New Space Group',
                   order: 3
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym space group' do
        patch api_v1_gym_gym_space_group_url(gym_id: @gym.id, id: @gym_space_group.id),
              params: {
                gym_space_group: {
                  name: 'Updated Name'
                }
              },
              headers: @user_headers, as: :json
        assert_response :success
        @gym_space_group.reload
        assert_equal 'Updated Name', @gym_space_group.name
      end

      test 'should destroy gym space group' do
        assert_difference('GymSpaceGroup.count', -1) do
          delete api_v1_gym_gym_space_group_url(gym_id: @gym.id, id: @gym_space_group.id),
                 headers: @user_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should not create gym space group if not authorized' do
        post api_v1_gym_gym_space_groups_url(gym_id: @gym.id),
             params: {
               gym_space_group: {
                 name: 'Unauthorized Group'
               }
             },
             headers: @other_user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
