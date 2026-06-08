# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymAdministrationRequestsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @user = users(:normal_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should create gym administration request' do
        assert_difference('GymAdministrationRequest.count', 1) do
          post api_v1_gym_gym_administration_requests_url(gym_id: @gym.id),
               params: {
                 gym_administration_request: {
                   justification: 'I am the owner',
                   email: 'owner@gym.com',
                   first_name: 'Gym',
                   last_name: 'Owner'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should not create gym administration request if not logged in' do
        post api_v1_gym_gym_administration_requests_url(gym_id: @gym.id),
             params: {
               gym_administration_request: {
                 justification: 'I am the owner',
                 email: 'owner@gym.com',
                 first_name: 'Gym',
                 last_name: 'Owner'
               }
             },
             as: :json
        assert_response :forbidden
      end

      test 'should return error if params are missing' do
        post api_v1_gym_gym_administration_requests_url(gym_id: @gym.id),
             params: {
               gym_administration_request: {
                 justification: '',
                 email: 'invalid-email',
                 first_name: '',
                 last_name: ''
               }
             },
             headers: @user_headers, as: :json
        assert_response :unprocessable_entity
      end
    end
  end
end
