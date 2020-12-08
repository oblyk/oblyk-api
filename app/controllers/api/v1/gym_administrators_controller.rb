# frozen_string_literal: true

module Api
  module V1
    class GymAdministratorsController < ApiController
      before_action :protected_by_session, only: %i[create update destroy index]
      before_action :set_gym
      before_action :protected_by_gym_administrator, only: %i[create update destroy index]
      before_action :set_gym_administrator, only: %i[update destroy]

      def index
        @gym_administrators = @gym.gym_administrators
      end

      def create
        @gym_administrator = GymAdministrator.new(gym_administrator_params)
        @gym_administrator.gym = @gym
        if @gym_administrator.save
          render 'api/v1/gym_administrators/show'
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_administrator.update(gym_administrator_params)
          render 'api/v1/gym_administrators/show'
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_administrator.delete
          render json: {}, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_administrator
        @gym_administrator = GymAdministrator.find params[:id]
      end

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def gym_administrator_params
        params.require(:gym_administrator).permit(
          :user_id,
          :level
        )
      end

      def protected_by_gym_administrator
        return if @current_user.super_admin

        not_authorized unless @gym.gym_administrators.where(user_id: @current_user.id).exist?
      end
    end
  end
end
