# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AlertsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @alert = alerts(:warning_alert)
        @crag = crags(:rocher_des_aures)
        @user = users(:normal_user)
        @super_admin = users(:super_admin_user)
        @api_headers = api_headers(user: :normal_user)
        @super_admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_alerts_url(alertable_type: 'Crag', alertable_id: @crag.id), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show alert' do
        get api_v1_alert_url(@alert), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @alert.id, json_response['id']
      end

      test 'should create alert if super admin' do
        assert_difference('Alert.count') do
          post api_v1_alerts_url,
               params: {
                 alert: {
                   description: 'New alert description',
                   alert_type: 'warning',
                   alertable_type: 'Crag',
                   alertable_id: @crag.id
                 }
               },
               headers: @super_admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create alert if not super admin' do
        assert_no_difference('Alert.count') do
          post api_v1_alerts_url,
               params: {
                 alert: {
                   description: 'New alert description',
                   alert_type: 'warning',
                   alertable_type: 'Crag',
                   alertable_id: @crag.id
                 }
               },
               headers: @api_headers,
               as: :json
        end
        assert_response :forbidden
      end

      test 'should update alert if super admin' do
        patch api_v1_alert_url(@alert),
              params: {
                alert: {
                  description: 'Updated description'
                }
              },
              headers: @super_admin_headers,
              as: :json
        assert_response :success
        @alert.reload
        assert_equal 'Updated description', @alert.description
      end

      test 'should not update alert if not super admin' do
        patch api_v1_alert_url(@alert),
              params: {
                alert: {
                  description: 'Updated description'
                }
              },
              headers: @api_headers,
              as: :json
        assert_response :forbidden
      end

      test 'should not create alert if invalid' do
        assert_no_difference('Alert.count') do
          post api_v1_alerts_url,
               params: {
                 alert: {
                   description: '',
                   alert_type: 'invalid_type',
                   alertable_type: 'Crag',
                   alertable_id: @crag.id
                 }
               },
               headers: @super_admin_headers,
               as: :json
        end
        assert_response :unprocessable_entity
      end

      test 'should destroy alert if super admin' do
        assert_difference('Alert.count', -1) do
          delete api_v1_alert_url(@alert), headers: @super_admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy alert if not super admin' do
        assert_no_difference('Alert.count') do
          delete api_v1_alert_url(@alert), headers: @api_headers, as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
