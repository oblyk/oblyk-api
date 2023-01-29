# frozen_string_literal: true

module Api
  module V1
    class GymOpenersController < ApiController
      before_action :protected_by_session
      before_action :set_gym
      before_action :set_gym_opener, only: %i[show update deactivate activate]
      before_action :protected_by_administrator

      def index
        gym_openers = case params.fetch(:activate, nil)
                      when 'true'
                        @gym.gym_openers.activated
                      when 'false'
                        @gym.gym_openers.deactivated
                      else
                        @gym.gym_openers
                      end
        render json: gym_openers.order(deactivated_at: :asc, name: :asc).map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_opener.detail_to_json, status: :ok
      end

      def create
        @gym_opener = GymOpener.new(gym_opener_params)
        @gym_opener.gym = @gym

        # Add user if existe
        if gym_opener_params[:email]
          user = User.find_by email: gym_opener_params[:email]
          @gym_opener.user = user
        end

        if @gym_opener.save
          render json: @gym_opener.detail_to_json, status: :ok
        else
          render json: { error: @gym_opener.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_opener.update(gym_opener_params)
          render json: @gym_opener.detail_to_json, status: :ok
        else
          render json: { error: @gym_opener.errors }, status: :unprocessable_entity
        end
      end

      def deactivate
        if @gym_opener.deactivate!
          render json: {}, status: :ok
        else
          render json: { error: @gym_opener.errors }, status: :unprocessable_entity
        end
      end

      def activate
        if @gym_opener.activate!
          render json: {}, status: :ok
        else
          render json: { error: @gym_opener.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_gym_opener
        @gym_opener = GymOpener.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def gym_opener_params
        params.require(:gym_opener).permit(
          :name,
          :first_name,
          :last_name,
          :email
        )
      end
    end
  end
end
