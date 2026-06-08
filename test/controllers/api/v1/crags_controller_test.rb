# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CragsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_crags_url, headers: @user_headers
        assert_response :success
      end

      test 'should search crags' do
        get search_api_v1_crags_url, params: { query: 'Rocher' }, headers: @user_headers
        assert_response :success
      end

      test 'should get random crag' do
        get random_api_v1_crags_url, headers: @user_headers
        assert_response :success
      end

      test 'should show crag' do
        get api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
      end

      test 'should create crag' do
        assert_difference('Crag.count') do
          post api_v1_crags_url,
               params: {
                 crag: {
                   name: 'New Crag',
                   rocks: ['limestone'],
                   latitude: 45.0,
                   longitude: 5.0,
                   city: 'Test City'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update crag' do
        put api_v1_crag_url(@crag),
            params: { crag: { name: 'Updated Crag Name' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @crag.reload
        assert_equal 'Updated Crag Name', @crag.name
      end

      test 'should destroy crag' do
        # We need a crag that can be destroyed (e.g. without dependent routes if there are constraints)
        # Or just a new one
        new_crag = Crag.create!(
          name: 'To Destroy',
          rocks: ['granite'],
          latitude: 46.0,
          longitude: 6.0,
          city: 'Destroy City',
          user: users(:normal_user)
        )
        assert_difference('Crag.count', -1) do
          delete api_v1_crag_url(new_crag), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
