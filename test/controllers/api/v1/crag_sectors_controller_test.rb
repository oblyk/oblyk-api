# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CragSectorsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @crag_sector = crag_sectors(:sector_one)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_crag_crag_sectors_url(@crag), headers: @user_headers
        assert_response :success
      end

      test 'should show crag_sector' do
        get api_v1_crag_sector_url(@crag_sector), headers: @user_headers
        assert_response :success
      end

      test 'should get versions' do
        get versions_api_v1_crag_sector_url(@crag_sector), headers: @user_headers
        assert_response :success
      end

      test 'should get photos' do
        get photos_api_v1_crag_sector_url(@crag_sector), headers: @user_headers
        assert_response :success
      end

      test 'should get videos' do
        get videos_api_v1_crag_sector_url(@crag_sector), headers: @user_headers
        assert_response :success
      end

      test 'should get route_figures' do
        get route_figures_api_v1_crag_sector_url(@crag_sector), headers: @user_headers
        assert_response :success
      end

      test 'should get geo_json_around' do
        get geo_json_around_api_v1_crag_crag_sectors_url(@crag), headers: @user_headers
        assert_response :success
      end

      test 'should get geo_json_around with exclusion' do
        get geo_json_around_api_v1_crag_crag_sectors_url(@crag), params: { exclude_id: @crag_sector.id }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        features = json_response['features']
        features.each do |feature|
          if feature['properties']['type'] == 'CragSector'
            assert_not_equal @crag_sector.id, feature['properties']['id']
          end
        end
      end

      test 'should create crag_sector' do
        assert_difference('CragSector.count') do
          post api_v1_crag_crag_sectors_url(@crag),
               params: {
                 crag_sector: {
                   name: 'New Sector',
                   latitude: 44.5,
                   longitude: 5.1
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create crag_sector with invalid params' do
        post api_v1_crag_crag_sectors_url(@crag),
             params: {
               crag_sector: {
                 name: ''
               }
             },
             headers: @user_headers,
             as: :json
        assert_response :unprocessable_entity
      end

      test 'should update crag_sector' do
        put api_v1_crag_crag_sector_url(@crag, @crag_sector),
            params: { crag_sector: { name: 'Updated Sector Name' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @crag_sector.reload
        assert_equal 'Updated Sector Name', @crag_sector.name
      end

      test 'should not update crag_sector with invalid params' do
        put api_v1_crag_crag_sector_url(@crag, @crag_sector),
            params: { crag_sector: { name: '' } },
            headers: @user_headers,
            as: :json
        assert_response :unprocessable_entity
      end

      test 'should destroy crag_sector' do
        assert_difference('CragSector.count', -1) do
          delete api_v1_crag_sector_url(@crag_sector), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy crag_sector if not super_admin' do
        assert_no_difference('CragSector.count') do
          delete api_v1_crag_sector_url(@crag_sector), headers: @user_headers, as: :json
        end
        assert_response :forbidden
      end

      test 'should not create crag_sector if not logged in' do
        assert_no_difference('CragSector.count') do
          post api_v1_crag_crag_sectors_url(@crag),
               params: {
                 crag_sector: {
                   name: 'New Sector'
                 }
               },
               headers: api_access_token_headers,
               as: :json
        end
        assert_response :unauthorized
      end

      test 'should not update crag_sector if not logged in' do
        put api_v1_crag_crag_sector_url(@crag, @crag_sector),
            params: { crag_sector: { name: 'Updated Sector Name' } },
            headers: api_access_token_headers,
            as: :json
        assert_response :unauthorized
      end
    end
  end
end
