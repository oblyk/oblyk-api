# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ApproachesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @approach = approaches(:approach_one)
        @user = users(:normal_user)
        @super_admin = users(:super_admin_user)
        @auth_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
        @public_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_crag_approaches_url(crag_id: @crag.id),
            headers: @public_headers,
            as: :json
        assert_response :success
        assert_equal @crag.approaches.count, JSON.parse(response.body).size
      end

      test 'should get geo_json_around' do
        get geo_json_around_api_v1_crag_approaches_url(crag_id: @crag.id, id: @approach.id),
            headers: @public_headers,
            as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert_kind_of Array, json_response['features']
      end

      test 'should show approach' do
        get api_v1_crag_approach_url(crag_id: @crag.id, id: @approach.id),
            headers: @public_headers,
            as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @approach.id, json_response['id']
      end

      test 'should create approach' do
        assert_difference('Approach.count') do
          post api_v1_crag_approaches_url(crag_id: @crag.id),
               params: {
                 approach: {
                   description: 'New approach',
                   length: 300,
                   approach_type: 'soft_ascent',
                   from_park: true,
                   polyline: [[44.469592, 5.058089], [44.470000, 5.060000]]
                 }
               },
               headers: @auth_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update approach' do
        put api_v1_crag_approach_url(crag_id: @crag.id, id: @approach.id),
            params: {
              approach: {
                description: 'Updated description',
                polyline: @approach.polyline
              }
            },
            headers: @auth_headers,
            as: :json
        assert_response :success
        @approach.reload
        assert_equal 'Updated description', @approach.description
      end

      test 'should not destroy approach if not super admin' do
        assert_no_difference('Approach.count') do
          delete api_v1_crag_approach_url(crag_id: @crag.id, id: @approach.id),
                 headers: @auth_headers,
                 as: :json
        end
        assert_response :forbidden
      end

      test 'should destroy approach if super admin' do
        assert_difference('Approach.count', -1) do
          delete api_v1_crag_approach_url(crag_id: @crag.id, id: @approach.id),
                 headers: @admin_headers,
                 as: :json
        end
        assert_response :success
      end
    end
  end
end
