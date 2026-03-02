# frozen_string_literal: true

module Api
  module V1
    class UserApplicationsController < ApiController
      before_action :protected_by_session
      before_action :set_application, only: %i[show destroy]

      def index
        render json: @current_user.user_applications.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @user_application.detail_to_json, status: :ok
      end

      def destroy
        @user_application.destroy
        head :no_content
      end

      private

      def set_application
        @user_application = @current_user.user_applications.find(params[:id])
      end
    end
  end
end
