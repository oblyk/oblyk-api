# frozen_string_literal: true

module Api
  module V1
    class GymAdministratorsController < ApiController
      include Gymable
      before_action :set_gym_administrator, only: %i[update destroy]

      def index
        @gym_administrators = @gym.gym_administrators
      end

      def create
        user = User.find_by email: gym_administrator_params[:email]
        @gym_administrator = GymAdministrator.new level: gym_administrator_params[:level]
        @gym_administrator.user = user
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
        if @gym_administrator.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_administrator
        @gym_administrator = GymAdministrator.find params[:id]
      end

      def gym_administrator_params
        params.require(:gym_administrator).permit(
          :email,
          :level
        )
      end
    end
  end
end
