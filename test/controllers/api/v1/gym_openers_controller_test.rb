# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymOpenersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @opener = gym_openers(:opener_one)
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
      end

      test 'should get index' do
        get api_v1_gym_gym_openers_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get index with activate true' do
        get api_v1_gym_gym_openers_url(gym_id: @gym.id), params: { activate: 'true' }, headers: @user_headers
        assert_response :success
      end

      test 'should show gym opener' do
        get api_v1_gym_gym_opener_url(gym_id: @gym.id, id: @opener.id), headers: @user_headers
        assert_response :success
      end

      test 'should create gym opener' do
        assert_difference('GymOpener.count', 1) do
          post api_v1_gym_gym_openers_url(gym_id: @gym.id),
               params: {
                 gym_opener: {
                   name: 'New Opener',
                   first_name: 'New',
                   last_name: 'Opener',
                   email: 'new.opener@test.com'
                 }
               },
               headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym opener' do
        patch api_v1_gym_gym_opener_url(gym_id: @gym.id, id: @opener.id),
              params: {
                gym_opener: {
                  name: 'Updated Name'
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @opener.reload
        assert_equal 'Updated Name', @opener.name
      end

      test 'should deactivate gym opener' do
        put deactivate_api_v1_gym_gym_opener_url(gym_id: @gym.id, id: @opener.id),
            headers: @admin_headers, as: :json
        assert_response :success
        @opener.reload
        assert_not_nil @opener.deactivated_at
      end

      test 'should activate gym opener' do
        @opener.deactivate!
        put activate_api_v1_gym_gym_opener_url(gym_id: @gym.id, id: @opener.id),
            headers: @admin_headers, as: :json
        assert_response :success
        @opener.reload
        assert_nil @opener.deactivated_at
      end

      test 'should not create gym opener if not authorized' do
        post api_v1_gym_gym_openers_url(gym_id: @gym.id),
             params: {
               gym_opener: {
                 name: 'Unauthorized Opener'
               }
             },
             headers: @user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
