# frozen_string_literal: true

module Api
  module V1
    class AscentCragRoutesController < ApiController
      before_action :protected_by_session
      before_action :set_ascent_crag_route, except: %i[create index export]
      before_action :protected_by_owner, only: %i[update destroy add_ascent_user remove_ascent_user]

      def index
        crag_route_id = params.fetch(:crag_route_id, nil)
        ascent_crag_routes = crag_route_id ? @current_user.ascent_crag_routes.where(crag_route_id: crag_route_id) : @current_user.ascent_crag_routes
        render json: ascent_crag_routes.map(&:summary_to_json), status: :ok
      end

      def export
        type = params.fetch(:type, 'ascents')
        ascents = if type == 'ascents'
                    @current_user.ascent_crag_routes.where.not(ascent_status: :project)
                  else
                    @current_user.ascent_crag_routes.where(ascent_status: :project)
                  end
        send_data ascents.to_csv, filename: "export-ascents-#{Date.current}.csv"
      end

      def show
        render json: @ascent_crag_route.detail_to_json, status: :ok
      end

      def create
        @ascent_crag_route = AscentCragRoute.new(ascent_crag_route_params)
        @ascent_crag_route.user = @current_user
        if @ascent_crag_route.save
          render json: @current_user.ascent_crag_routes_to_a, status: :created
        else
          render json: { error: @ascent_crag_route.errors }, status: :unprocessable_entity
        end
      end

      def add_ascent_user
        ascent_user = AscentUser.new user_id: ascent_user_params[:user_id], ascent: @ascent_crag_route
        if ascent_user.save
          head :no_content
        else
          render json: { error: ascent_user.errors }, status: :unprocessable_entity
        end
      end

      def remove_ascent_user
        ascent_user = AscentUser.find_by ascent: @ascent_crag_route, user_id: ascent_user_params[:user_id]
        ascent_user.destroy
        head :no_content
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
          :hardness_status,
          :note,
          :comment,
          :private_comment,
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
        forbidden if @current_user.id != @ascent_crag_route.user_id
      end
    end
  end
end
