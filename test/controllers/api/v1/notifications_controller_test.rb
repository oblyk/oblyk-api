# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class NotificationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @api_headers = api_headers(user: :normal_user)
        @notification = notifications(:new_message_notif)
      end

      test 'should get index' do
        get api_v1_notifications_url, headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response
      end

      test 'should get index with unread_only false' do
        get api_v1_notifications_url, headers: @api_headers, params: { unread_only: 'false' }
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_not_empty json_response
      end

      test 'should get unread count' do
        get unread_count_api_v1_notifications_url, headers: @api_headers, as: :json
        assert_response :success
        assert_equal @user.notifications.unread.count, JSON.parse(response.body)
      end

      test 'should mark notification as read' do
        @notification.update_column(:read_at, nil)
        assert_nil @notification.read_at
        put read_api_v1_notification_url(@notification), headers: @api_headers, as: :json
        assert_response :no_content
        @notification.reload
        assert_not_nil @notification.read_at
      end

      test 'should mark all notifications as read' do
        @user.notifications.update_all(read_at: nil)
        assert @user.notifications.unread.count.positive?
        put read_all_api_v1_notifications_url, headers: @api_headers, as: :json
        assert_response :no_content
        assert_equal 0, @user.notifications.unread.count
      end
    end
  end
end
