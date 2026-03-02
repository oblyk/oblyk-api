# frozen_string_literal: true

module Api
  module V1
    class UserApplicationMyCompetsController < ApiController
      before_action :protected_by_session

      def index
        my_compet = @current_user.user_application_my_compet
        if my_compet
          render json: my_compet.summary_to_json, status: :ok
        else
          render json: nil, status: :not_found
        end
      end

      def create
        application = UserApplicationMyCompet.new application_params
        application.user = @current_user
        unless application.valid?
          render json: { error: application.errors }, status: :unprocessable_entity
          return
        end

        my_compet_response = MyCompet.association_request application
        application.status = my_compet_response.try(:[], 'status') || 'ERROR'
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
