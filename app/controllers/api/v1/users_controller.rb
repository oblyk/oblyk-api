# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :protected_by_session, except: %i[index]
      before_action :set_user, except: %i[index]

      def index
        @users = User.all
      end

      def subscribes
        @subscribes = @user.subscribes.where.not(followable_type: %w[GuideBookPaper User]).order(views: :desc)
      end

      def ascents_crag_routes
        render json: @user.ascent_crag_routes_to_a, status: :ok
      end

      def library
        @subscribes = @user.subscribes.where(followable_type: %w[GuideBookPaper]).order(views: :desc)
        render 'api/v1/users/subscribes'
      end

      def tick_lists
        @crag_routes = @user.ticked_crag_routes.joins(:crag).order('crags.name')
        render 'api/v1/crag_routes/index'
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
