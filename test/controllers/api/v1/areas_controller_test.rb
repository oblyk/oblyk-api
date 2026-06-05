# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AreasControllerTest < ActionDispatch::IntegrationTest
      setup do
        @area = areas(:foret_de_saou)
        @crag = crags(:rocher_des_aures)
        @crag_orpierre = crags(:orpierre)
        @user = users(:normal_user)
        @super_admin = users(:super_admin_user)
        @api_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_areas_url, headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should search areas' do
        get search_api_v1_areas_url(query: 'Saoû'), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should show area' do
        get api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get crags' do
        get crags_api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get crags figures' do
        get crags_figures_api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get guide book papers' do
        get guide_book_papers_api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get geo json' do
        get geo_json_api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should get photos' do
        get photos_api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should create area' do
        assert_difference('Area.count') do
          post api_v1_areas_url,
               params: { area: { name: 'New Area' } },
               headers: @api_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update area' do
        patch api_v1_area_url(@area),
              params: { area: { name: 'Updated Name' } },
              headers: @api_headers,
              as: :json
        assert_response :success
        @area.reload
        assert_equal 'Updated Name', @area.name
      end

      test 'should add crag to area' do
        post add_crag_api_v1_area_url(@area),
             params: { area: { crag_id: @crag_orpierre.id } },
             headers: @api_headers,
             as: :json
        assert_response :success
      end

      test 'should remove crag from area' do
        # First add it to be sure it's there
        AreaCrag.create(area: @area, crag: @crag, user: @user)
        
        delete remove_crag_api_v1_area_url(@area),
               params: { area: { crag_id: @crag.id } },
               headers: @api_headers,
               as: :json
        assert_response :success
      end

      test 'should not destroy area if not super admin' do
        delete api_v1_area_url(@area), headers: @api_headers, as: :json
        assert_response :forbidden
      end

      test 'should destroy area if super admin' do
        super_admin_headers = api_headers(user: :super_admin_user)
        assert_difference('Area.count', -1) do
          delete api_v1_area_url(@area), headers: super_admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
