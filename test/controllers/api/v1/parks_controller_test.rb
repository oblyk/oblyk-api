# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ParksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @park = parks(:park_one)
        @user_headers = api_headers(user: :normal_user)
        @super_admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_crag_parks_url(crag_id: @crag.id), headers: api_access_token_headers
        assert_response :success
      end

      test 'should show park' do
        get api_v1_crag_park_url(crag_id: @crag.id, id: @park.id), headers: api_access_token_headers
        assert_response :success
      end

      test 'should get geo_json_around' do
        get geo_json_around_api_v1_crag_parks_url(crag_id: @crag.id), headers: api_access_token_headers
        assert_response :success
      end

      test 'should create park' do
        assert_difference('Park.count', 1) do
          post api_v1_crag_parks_url(crag_id: @crag.id),
               params: {
                 park: {
                   description: 'Nouveau parking',
                   latitude: 44.47,
                   longitude: 5.06
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update park' do
        patch api_v1_crag_park_url(crag_id: @crag.id, id: @park.id),
              params: {
                park: {
                  description: 'Parking mis à jour'
                }
              },
              headers: @user_headers, as: :json
        assert_response :success
        @park.reload
        assert_equal 'Parking mis à jour', @park.description
      end

      test 'should not destroy park if not super admin' do
        assert_no_difference('Park.count') do
          delete api_v1_crag_park_url(crag_id: @crag.id, id: @park.id), headers: @user_headers
        end
        assert_response :forbidden
      end

      test 'should destroy park if super admin' do
        assert_difference('Park.count', -1) do
          delete api_v1_crag_park_url(crag_id: @crag.id, id: @park.id), headers: @super_admin_headers
        end
        assert_response :success
      end
    end
  end
end
