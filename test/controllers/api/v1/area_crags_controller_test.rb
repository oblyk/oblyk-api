# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AreaCragsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @area = areas(:foret_de_saou)
        @crag = crags(:orpierre)
        @area_crag = area_crags(:one)
        @user = users(:normal_user)
        @super_admin = users(:super_admin_user)
        @api_headers = api_headers(user: :normal_user)
        @super_admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should create area_crag' do
        assert_difference('AreaCrag.count') do
          post api_v1_area_crags_url,
               params: { area_crag: { area_id: @area.id, crag_id: @crag.id } },
               headers: @api_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create area_crag if not logged in' do
        assert_no_difference('AreaCrag.count') do
          post api_v1_area_crags_url,
               params: { area_crag: { area_id: @area.id, crag_id: @crag.id } },
               as: :json
        end
        assert_response :forbidden
      end

      test 'should not create area_crag if invalid' do
        duplicate_crag = area_crags(:one).crag
        assert_no_difference('AreaCrag.count') do
          post api_v1_area_crags_url,
               params: { area_crag: { area_id: @area.id, crag_id: duplicate_crag.id } },
               headers: @api_headers,
               as: :json
        end
        assert_response :unprocessable_entity
      end

      test 'should destroy area_crag if super_admin' do
        assert_difference('AreaCrag.count', -1) do
          delete api_v1_area_crag_url(@area_crag), headers: @super_admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy area_crag if not super_admin' do
        assert_no_difference('AreaCrag.count') do
          delete api_v1_area_crag_url(@area_crag), headers: @api_headers, as: :json
        end
        assert_response :forbidden
      end

      test 'should not destroy area_crag if not logged in' do
        assert_no_difference('AreaCrag.count') do
          delete api_v1_area_crag_url(@area_crag), as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
