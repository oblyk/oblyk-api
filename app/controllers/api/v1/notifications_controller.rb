# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < ApiController
      before_action :protected_by_session
      before_action :set_notification, only: %i[read]

      def index
        unread_only = params.fetch(:unread_only, 'true')
        @notifications = unread_only == 'true' ? @current_user.notifications.unread : @current_user.notifications.page(params.fetch(:page, 1))
      end

      def unread_count
        render json: @current_user.notifications.unread.count, status: :ok
      end

      def read
        @notification.read!
        head :no_content
      end

      def read_all
        @current_user.notifications.unread.each(&:read!)
        head :no_content
      end

      private

      def set_notification
        @notification = @current_user.notifications.find params[:id]
      end
    end
  end
end
