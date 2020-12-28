# frozen_string_literal: true

module Api
  module V1
    class GymAdministrationRequestsController < ApiController
      before_action :protected_by_session
      before_action :set_gym

      def create
        @gym_administration_request = GymAdministrationRequest.new(gym_administration_request_params)
        @gym_administration_request.gym = @gym
        @gym_administration_request.user = @current_user
        if @gym_administration_request.save
          render json: {}, status: :ok
        else
          render json: { error: @gym_administration_request.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def gym_administration_request_params
        params.require(:gym_administration_request).permit(
          :justification,
          :email,
          :first_name,
          :last_name
        )
      end
    end
  end
end
