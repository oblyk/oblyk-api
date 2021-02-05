# frozen_string_literal: true

module Api
  module V1
    class AscentCragRoutesController < ApiController
      before_action :protected_by_session, only: %i[index create update destroy]
      before_action :set_ascent_crag_route, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        crag_route_id = params.fetch(:crag_route_id, nil)
        @ascent_crag_routes = crag_route_id ? @current_user.ascent_crag_routes.where(crag_route_id: crag_route_id) : @current_user.ascents_crag_routes
      end

      def show; end

      def create
        @ascent_crag_route = AscentCragRoute.new(ascent_crag_route_params)
        @ascent_crag_route.user = @current_user
        if @ascent_crag_route.save
          render json: @current_user.ascent_crag_routes_to_a, status: :created
        else
          render json: { error: @ascent_crag_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @ascent_crag_route.update(ascent_crag_route_params)
          render json: @current_user.ascent_crag_routes_to_a, status: :created
        else
          render json: { error: @ascent_crag_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @ascent_crag_route.destroy
          render json: @current_user.ascent_crag_routes_to_a, status: :created
        else
          render json: { error: @ascent_crag_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_ascent_crag_route
        @ascent_crag_route = AscentCragRoute.find params[:id]
      end

      def ascent_crag_route_params
        params.require(:ascent_crag_route).permit(
          :ascent_status,
          :roping_status,
          :attempt,
          :crag_route_id,
          :grade_appreciation_text,
          :note,
          :comment,
          :private_comment,
          :released_at,
          selected_sections: %i[]
        )
      end

      def protected_by_owner
        not_authorized if @current_user.id != @ascent_crag_route.user_id
      end
    end
  end
end
