# frozen_string_literal: true

module Api
  module V1
    class AscentGymRoutesController < ApiController
      before_action :protected_by_session
      before_action :set_ascent_gym_route, except: %i[create index]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        gym_route_id = params.fetch(:gym_route_id, nil)
        @ascent_gym_routes = gym_route_id ? @current_user.ascent_gym_routes.where(gym_route_id: gym_route_id) : @current_user.ascent_gym_routes
      end

      def show; end

      def create
        @ascent_gym_route = AscentGymRoute.new(ascent_gym_route_params)
        @ascent_gym_route.user = @current_user
        if @ascent_gym_route.save
          render json: @current_user.ascent_gym_routes_to_a, status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @ascent_gym_route.update(ascent_gym_route_params)
          render json: @current_user.ascent_gym_routes_to_a, status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @ascent_gym_route.destroy
          render json: @current_user.ascent_gym_routes_to_a, status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_ascent_gym_route
        @ascent_gym_route = AscentGymRoute.find params[:id]
      end

      def ascent_gym_route_params
        params.require(:ascent_gym_route).permit(
          :ascent_status,
          :roping_status,
          :gym_route_id,
          :gym_id,
          :gym_grade_id,
          :level,
          :note,
          :comment,
          :released_at,
          selected_sections: %i[]
        )
      end

      def ascent_user_params
        params.require(:ascent_user).permit(
          :user_id
        )
      end

      def protected_by_owner
        not_authorized if @current_user.id != @ascent_gym_route.user_id
      end
    end
  end
end
