# frozen_string_literal: true

module Api
  module V1
    class UserApplicationFfmeMyCompetsController < ApiController
      before_action :protected_by_session

      def create
        application = UserApplicationFfmeMyCompet.new application_params
        application.user = @current_user
        if application.save
          render json: application.summary_to_json, status: :ok
        else
          render json: { error: application.errors }, status: :unprocessable_entity
        end
      end

      private

      def application_params
        params.require(:application).permit(
          :ffme_licence_number
        )
      end
    end
  end
end
