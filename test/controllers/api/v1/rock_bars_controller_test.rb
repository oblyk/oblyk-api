# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class RockBarsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @rock_bar = rock_bars(:rock_bar_one)
        @user = users(:normal_user)
        @super_admin = users(:super_admin_user)
        @api_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_crag_rock_bars_url(crag_id: @crag.id), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @crag.rock_bars.count, json_response.size
      end

      test 'should show rock_bar' do
        get api_v1_crag_rock_bar_url(crag_id: @crag.id, id: @rock_bar.id), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @rock_bar.id, json_response['id']
      end

      test 'should create rock_bar' do
        assert_difference('RockBar.count') do
          post api_v1_crag_rock_bars_url(crag_id: @crag.id),
               params: {
                 rock_bar: {
                   polyline: [[44.1, 5.1], [44.2, 5.2]],
                   crag_sector_id: crag_sectors(:sector_one).id
                 }
               },
               headers: @api_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update rock_bar' do
        patch api_v1_crag_rock_bar_url(crag_id: @crag.id, id: @rock_bar.id),
              params: {
                rock_bar: {
                  polyline: [[44.3, 5.3], [44.4, 5.4]]
                }
              },
              headers: @api_headers,
              as: :json
        assert_response :success
        @rock_bar.reload
        assert_equal [[44.3, 5.3], [44.4, 5.4]], @rock_bar.polyline
      end

      test 'should destroy rock_bar if super_admin' do
        assert_difference('RockBar.count', -1) do
          delete api_v1_crag_rock_bar_url(crag_id: @crag.id, id: @rock_bar.id), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy rock_bar if not super_admin' do
        assert_no_difference('RockBar.count') do
          delete api_v1_crag_rock_bar_url(crag_id: @crag.id, id: @rock_bar.id), headers: @api_headers, as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
