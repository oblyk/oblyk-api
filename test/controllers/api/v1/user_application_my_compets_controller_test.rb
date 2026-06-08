# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class UserApplicationMyCompetsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @api_headers = api_headers(user: :normal_user)
      end

      test 'should get index when my_compet exists' do
        get api_v1_user_application_my_compets_url, headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'UserApplicationMyCompet', json_response['type']
        assert_equal '123456', json_response['ffme_licence_number']
      end

      test 'should get 404 on index when my_compet does not exist' do
        # On utilise un autre utilisateur qui n'a pas d'application
        other_user_headers = api_headers(user: :other_user)
        get api_v1_user_application_my_compets_url, headers: other_user_headers, as: :json
        assert_response :not_found
      end

      test 'should create my_compet application' do
        # On supprime l'application existante pour pouvoir en créer une nouvelle (unicité user_id + type)
        user_applications(:my_compet_app).destroy

        mock_response = { 'status' => 'IN_REVIEW' }
        
        MyCompet.stub :association_request, mock_response do
          assert_difference('UserApplicationMyCompet.count', 1) do
            post api_v1_user_application_my_compets_url,
                 params: { application: { ffme_licence_number: '654321' } },
                 headers: @api_headers,
                 as: :json
          end
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 'IN_REVIEW', json_response['status']
          assert_equal '654321', json_response['ffme_licence_number']
        end
      end

      test 'should return error on create with invalid params' do
        post api_v1_user_application_my_compets_url,
             params: { application: { ffme_licence_number: '' } },
             headers: @api_headers,
             as: :json
        assert_response :unprocessable_entity
      end
    end
  end
end
