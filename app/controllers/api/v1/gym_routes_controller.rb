# frozen_string_literal: true

module Api
  module V1
    class GymRoutesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space
      before_action :set_gym_sector, except: %i[index show]
      before_action :set_gym_route, only: %i[show update destroy]

      def index
        @gym_routes = if @gym_sector.present?
                        @gym_sector.gym_routes
                      elsif @gym_space.present?
                        @gym_space.gym_routes
                      else
                        @gym.gym_routes
                      end
      end

      def show; end

      def create
        @gym_route = GymRoute.new(gym_route_params)
        @gym_route.gym_sector = @gym_sector
        if @gym_route.save
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_route.update(gym_route_params)
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_route.delete
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space
        @gym_space = GymSpace.find_by params[:gym_space_id]
      end

      def set_gym_sector
        @gym_sector = GymSector.find_by params[:gym_sector_id]
      end

      def set_gym_route
        @gym_route = GymRoute.find params[:id]
      end

      def gym_route_params
        params.require(:gym_route).permit(
          :name,
          :height,
          :climbing_type,
          :openers,
          :polyline,
          :gym_grade_line_id,
          sections: %i[climbing_type description grade height],
          hold_colors: %i[],
          tag_colors: %i[]
        )
      end
    end
  end
end
