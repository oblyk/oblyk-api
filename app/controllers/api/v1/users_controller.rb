# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :protected_by_session, except: %i[index]
      before_action :set_user, only: %i[show update add_avatar add_banner]

      def index
        @users = User.all
      end

      def show; end

      def update
        if @user.update(user_params)
          render 'api/v1/users/show'
        else
          render json: @user.errors, status: :internal_server_error
        end
      end

      def add_banner
        if @user.update(banner_params)
          render 'api/v1/users/show'
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def add_avatar
        if @user.update(avatar_params)
          render 'api/v1/users/show'
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = @current_user
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :date_of_birth,
          :genre,
          :description,
          :latitude,
          :longitude,
          :localization,
          :partner_search,
          :bouldering,
          :sport_climbing,
          :multi_pitch,
          :trad_climbing,
          :aid_climbing,
          :deep_water,
          :via_ferrata,
          :pan,
          :grade_max,
          :grade_min,
          :language
        )
      end

      def banner_params
        params.require(:user).permit(
          :banner
        )
      end

      def avatar_params
        params.require(:user).permit(
          :avatar
        )
      end
    end
  end
end
