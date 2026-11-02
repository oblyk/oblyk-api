# frozen_string_literal: true

module Api
  module V1
    class SprayWallRoutesController < ApiController
      before_action :protected_by_session, except: %i[index show]
      before_action :set_current_user, only: %i[index show]
      before_action :set_gym
      before_action :set_spray_wall
      before_action :set_spray_wall_route, except: %i[index show create]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        page = params.fetch(:page, 1).to_i
        render json: serializer(
          SprayWallRouteSerializer,
          @spray_wall.spray_wall_routes.includes(:gym, :spray_wall, spray_wall_route_holds: :spray_wall_hold).page(page),
          {
            include: %i[spray_wall_route_holds spray_wall_route_holds.spray_wall_hold],
            params: { current_user: @current_user }
          }
        ), status: :ok
      end

      def show
        spray_wall_route = @spray_wall.spray_wall_routes.includes(:spray_wall_route_holds, spray_wall: :gym).find params[:id]
        render json: serializer(
          SprayWallRouteSerializer,
          spray_wall_route,
          {
            include: %i[spray_wall_route_holds],
            params: { current_user: @current_user }
          }
        ), status: :ok
      end

      def create
        spray_wall_route = SprayWallRoute.new(spray_wall_route_params)
        spray_wall_route.spray_wall = @spray_wall
        spray_wall_route.user = @current_user
        if spray_wall_route.save
          render json: serializer(
            SprayWallRouteSerializer,
            spray_wall_route,
            {
              include: %i[spray_wall_route_holds],
              params: { current_user: @current_user }
            }
          ), status: :ok
        else
          render json: { error: spray_wall_route.errors }, status: :unprocessable_content
        end
      end

      def update
        if @spray_wall_route.update(spray_wall_route_params)
          render json: serializer(
            SprayWallRouteSerializer,
            @spray_wall_route,
            {
              include: %i[spray_wall_route_holds],
              params: { current_user: @current_user }
            }
          ), status: :ok
        else
          render json: { error: @spray_wall_route.errors }, status: :unprocessable_content
        end
      end

      def destroy
        if @spray_wall_route.destroy
          head :no_content
        else
          render json: { error: @spray_wall_route.errors }, status: :unprocessable_content
        end
      end

      private

      def set_current_user
        login?
      end

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_spray_wall
        @spray_wall = @gym.spray_walls.includes(picture_attachment: :blob).find params[:spray_wall_id]
      end

      def set_spray_wall_route
        @spray_wall_route = @spray_wall.spray_wall_routes.find params[:id]
      end

      def spray_wall_route_params
        params.require(:spray_wall_route).permit(
          :name,
          :comment,
          :level_index,
          :grade_text,
          :foot_authorization,
          :sub_level,
          :circus,
          styles: [],
          spray_wall_route_holds_attributes: %i[spray_wall_hold_id hold_type number]
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @spray_wall_route.user_id
      end
    end
  end
end
