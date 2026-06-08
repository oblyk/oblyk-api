# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class LocalityUsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @locality_user = locality_users(:lu_jean_paris)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_locality_users_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should get index with only_active' do
        get api_v1_locality_users_url, params: { only_active: 'true' }, headers: @user_headers
        assert_response :success
      end

      test 'should show locality_user' do
        get api_v1_locality_user_url(@locality_user), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @locality_user.id, json_response['id']
      end

      test 'should create locality_user' do
        mock_response = {
          'address' => {
            'city' => 'Grenoble',
            'country_code' => 'fr',
            'state' => 'Isère'
          },
          'lat' => 45.1885,
          'lon' => 5.7245
        }

        OpenStreetMapApi.stub :reverse_geocoding, mock_response do
          assert_difference('LocalityUser.count', 1) do
            post api_v1_locality_users_url,
                 params: { locality_user: { latitude: 45.1885, longitude: 5.7245 } },
                 headers: @user_headers, as: :json
          end
          assert_response :success
        end
      end

      test 'should update locality_user' do
        put api_v1_locality_user_url(@locality_user),
            params: { locality_user: { description: 'Nouvelle description', radius: 30 } },
            headers: @user_headers, as: :json
        assert_response :success
        @locality_user.reload
        assert_equal 'Nouvelle description', @locality_user.description
        assert_equal 30, @locality_user.radius
      end

      test 'should deactivate locality_user' do
        put deactivate_api_v1_locality_user_url(@locality_user), headers: @user_headers
        assert_response :no_content
        @locality_user.reload
        assert_not_nil @locality_user.deactivated_at
      end

      test 'should activate locality_user' do
        @locality_user.deactivate!
        put activate_api_v1_locality_user_url(@locality_user), headers: @user_headers
        assert_response :no_content
        @locality_user.reload
        assert_nil @locality_user.deactivated_at
      end

      test 'should destroy locality_user' do
        assert_difference('LocalityUser.count', -1) do
          delete api_v1_locality_user_url(@locality_user), headers: @user_headers
        end
        assert_response :no_content
      end
    end
  end
end
