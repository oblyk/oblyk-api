# frozen_string_literal: true

module Api
  module V1
    class LocalityUsersController < ApiController
      before_action :protected_by_session
      before_action :set_locality_user, only: %i[show update activate deactivate destroy]

      def index
        active = params.fetch(:only_active, 'false') != 'false'
        locality_users = active ? @current_user.locality_users.activated : @current_user.locality_users
        render json: locality_users.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @locality_user.detail_to_json, status: :ok
      end

      def create
        locality_user = LocalityUser.new(create_locality_user_params)
        locality_user.user = @current_user
        locality_user.partner_search = true
        locality_user.local_sharing = true
        if locality_user.create_by_reverse_geocoding!
          render json: locality_user.detail_to_json, status: :ok
        else
          render json: { error: locality_user.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @locality_user.update(update_locality_user_params)
          render json: @locality_user.detail_to_json, status: :ok
        else
          render json: { error: @locality_user.errors }, status: :unprocessable_entity
        end
      end

      def deactivate
        @locality_user.deactivate!
        head :no_content
      end

      def activate
        @locality_user.activate!
        head :no_content
      end

      def destroy
        @locality_user.destroy
        head :no_content
      end

      private

      def set_locality_user
        @locality_user = LocalityUser.where(user: @current_user).find params[:id]
      end

      def create_locality_user_params
        params.require(:locality_user).permit(
          :latitude,
          :longitude
        )
      end

      def update_locality_user_params
        params.require(:locality_user).permit(
          :description,
          :local_sharing,
          :partner_search,
          :radius
        )
      end
    end
  end
end
