# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymAdministrationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @super_admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :normal_user)
        @gym = gyms(:my_gym)
      end

      test 'should get assigned gyms' do
        @gym.administered!
        get assigned_api_v1_gym_administrations_url, headers: @super_admin_headers
        assert_response :success
      end

      test 'should get requested gyms' do
        get requested_api_v1_gym_administrations_url, headers: @super_admin_headers
        assert_response :success
      end

      test 'should accept request' do
        request = gym_administration_requests(:gym_administration_request_one)
        assert_difference('GymAdministrator.count', 1) do
          put accept_request_api_v1_gym_administrations_url,
               params: { id: request.id, gym_type: 'commercial_gym' },
               headers: @super_admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should delete request' do
        request = gym_administration_requests(:gym_administration_request_one)
        assert_difference('GymAdministrationRequest.count', -1) do
          delete delete_request_api_v1_gym_administrations_url,
                 params: { id: request.id },
                 headers: @super_admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should add option' do
        assert_difference('GymOption.count', 1) do
          post add_option_api_v1_gym_administrations_url,
               params: { gym_id: @gym.id, option_type: GymOption::OPTION_PRINT_LABEL },
               headers: @super_admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should delete option' do
        # On ajoute d'abord l'option pour être sûr qu'elle existe
        GymOption.find_or_create_by(gym: @gym, option_type: GymOption::OPTION_PRINT_LABEL) do |option|
          option.start_date = Date.current
        end
        assert_difference('GymOption.count', -1) do
          delete delete_option_api_v1_gym_administrations_url,
                 params: { gym_id: @gym.id, option_type: GymOption::OPTION_PRINT_LABEL },
                 headers: @super_admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should not be accessible by normal user' do
        get requested_api_v1_gym_administrations_url, headers: @user_headers
        assert_response :forbidden
      end
    end
  end
end
