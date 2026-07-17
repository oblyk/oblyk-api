# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymChainsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym_chain = gym_chains(:arkose)
        @user = users(:normal_user)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :other_user)
        @public_headers = api_access_token_headers
      end

      test 'should get gyms geo json' do
        get gyms_geo_json_api_v1_gym_chain_url(@gym_chain.slug_name), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
      end

      test 'should show gym chain' do
        get api_v1_gym_chain_url(@gym_chain.slug_name), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @gym_chain.name, json_response['name']
      end

      test 'should update gym chain if administrator' do
        patch api_v1_gym_chain_url(@gym_chain.slug_name),
              params: { gym_chain: { name: 'Arkose New Name' } },
              headers: @user_headers, as: :json
        assert_response :success
        @gym_chain.reload
        assert_equal 'Arkose New Name', @gym_chain.name
      end

      test 'should not update gym chain if not administrator' do
        patch api_v1_gym_chain_url(@gym_chain.slug_name),
              params: { gym_chain: { name: 'Hacker Name' } },
              headers: @other_user_headers, as: :json
        assert_response :forbidden
      end

      test 'should not update gym chain if not logged in' do
        patch api_v1_gym_chain_url(@gym_chain.slug_name),
              params: { gym_chain: { name: 'Anonymous Name' } },
              headers: @public_headers,
              as: :json
        assert_response :unauthorized
      end

      test 'should fail update with invalid params' do
        patch api_v1_gym_chain_url(@gym_chain.slug_name),
              params: { gym_chain: { name: '' } },
              headers: @user_headers, as: :json
        assert_response :unprocessable_content
      end

      test 'should add banner' do
        banner_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post add_banner_api_v1_gym_chain_url(@gym_chain.slug_name),
             params: { gym_chain: { banner: banner_file } },
             headers: @user_headers
        assert_response :success
        @gym_chain.reload
        assert @gym_chain.banner.attached?
      end

      test 'should add logo' do
        logo_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post add_logo_api_v1_gym_chain_url(@gym_chain.slug_name),
             params: { gym_chain: { logo: logo_file } },
             headers: @user_headers
        assert_response :success
        @gym_chain.reload
        assert @gym_chain.logo.attached?
      end
    end
  end
end
