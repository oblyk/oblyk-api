# frozen_string_literal: true

module Api
  module V1
    class GymAdministratorsController < ApiController
      include Gymable

      before_action :set_gym_administrator, only: %i[update show destroy]
      before_action -> { can? GymRole::MANAGE_TEAM_MEMBER }, except: %i[index show]

      def index
        gym_administrators = @gym.gym_administrators
        render json: gym_administrators.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_administrator.detail_to_json, status: :ok
      end

      def create
        user = User.find_by email: gym_administrator_params[:requested_email]
        @gym_administrator = GymAdministrator.new gym_administrator_params
        @gym_administrator.user = user
        @gym_administrator.gym = @gym
        if @gym_administrator.save
          @gym_administrator.send_invitation_email! @current_user
          render json: @gym_administrator.detail_to_json, status: :ok
        else
          render json: { error: @gym_administrator.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_administrator.update gym_administrator_params
          render json: @gym_administrator.detail_to_json, status: :ok
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
          :id,
          :requested_email,
          roles: []
        )
      end
    end
  end
end
