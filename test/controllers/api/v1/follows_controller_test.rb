# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class FollowsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @crag = crags(:rocher_des_aures)
        @gym = gyms(:my_gym)

        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_follows_url,
            params: { followable_type: 'Crag', followable_id: @crag.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should get followers' do
        get followers_api_v1_follows_url,
            params: { followable_type: 'Crag', followable_id: @crag.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should create follow' do
        new_crag = crags(:orpierre)
        assert_difference('Follow.count', 1) do
          post api_v1_follows_url,
               params: { follow: { followable_type: 'Crag', followable_id: new_crag.id } },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should destroy follow' do
        assert_difference('Follow.count', -1) do
          delete api_v1_follows_url,
                 params: { followable_type: 'Crag', followable_id: @crag.id },
                 headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should increment follow' do
        follow = follows(:follow_user_to_crag)
        put increment_api_v1_follows_url,
            params: { followable_type: 'Crag', followable_id: @crag.id },
            headers: @user_headers, as: :json
        assert_response :success
        follow.reload
      end

      test 'should get my follows by types' do
        get my_follows_by_types_api_v1_follows_url,
            params: { followable_types: ['Crag', 'Gym'] },
            headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('Crag')
        assert json_response.key?('Gym')
      end

      test 'should not destroy follow of another user' do
        delete api_v1_follows_url,
               params: { followable_type: 'User', followable_id: @user.id },
               headers: @user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
