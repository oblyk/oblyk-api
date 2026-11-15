# frozen_string_literal: true

module Api
  module V1
    class SprayWallRoutesController < ApiController
      before_action :protected_by_session, except: %i[index show available_filters]
      before_action :set_current_user, only: %i[index show]
      before_action :set_gym
      before_action :set_spray_wall
      before_action :set_spray_wall_route, except: %i[index show create available_filters]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        order_by = params.fetch(:order_by, nil)
        direction = params.fetch(:direction, "asc") == "asc" ? "ASC" : "DESC"
        page = params.fetch(:page, 1).to_i
        filters = params.fetch(:filters, [])
        filters = filters.map { |filter| JSON.parse(filter) }

        routes = @spray_wall.spray_wall_routes.includes(:gym, :spray_wall, spray_wall_route_holds: :spray_wall_hold)

        filters.each do |filter|
          if filter["type"] == "style" && ClimbingStyle::STYLE_LIST.include?(filter["value"])
            routes = routes.where("JSON_CONTAINS(spray_wall_routes.styles, JSON_QUOTE(:style))", style: filter["value"])
          elsif filter["type"] == "user"
            routes = routes.where(user_id: filter["value"].to_i)
          elsif filter["type"] == "spray_wall_hold"
            routes = routes.where(
              SprayWallRouteHold.where("spray_wall_route_holds.spray_wall_route_id = spray_wall_routes.id")
                                .where(spray_wall_hold_id: filter["value"].to_i)
                                .arel
                                .exists
            )
          end
        end

        routes = case order_by
                 when "opened_at"
                   routes.order(Arel.sql("spray_wall_routes.created_at #{direction}, spray_wall_routes.id"))
                 when "difficulty"
                   routes.order(Arel.sql("COALESCE(spray_wall_routes.level_index, spray_wall_routes.grade_value) #{direction}, spray_wall_routes.id"))
                 when "ascents_count"
                   routes.order(Arel.sql("spray_wall_routes.ascents_count #{direction}, spray_wall_routes.id"))
                 when "likes_count"
                   routes.order(Arel.sql("spray_wall_routes.likes_count #{direction}, spray_wall_routes.id"))
                 when "comments_count"
                   routes.order(Arel.sql("spray_wall_routes.all_comments_count #{direction}, spray_wall_routes.id"))
                 else
                   routes
                 end

        routes = routes.page(page)
        render json: serializer(
          SprayWallRouteSerializer,
          routes,
          {
            include: %i[spray_wall_route_holds spray_wall_route_holds.spray_wall_hold],
            params: { current_user: @current_user }
          }
        ), status: :ok
      end

      def show
        spray_wall_route = @spray_wall.spray_wall_routes
                                      .includes(:spray_wall_route_holds, spray_wall_route_holds: :spray_wall_hold, spray_wall: :gym)
                                      .find(params[:id])
        render json: serializer(
          SprayWallRouteSerializer,
          spray_wall_route,
          {
            include: %i[spray_wall spray_wall_route_holds spray_wall_route_holds.spray_wall_hold user],
            params: {
              current_user: @current_user,
              include_attachments: {
                SprayWall: %i[picture],
                User: %i[avatar]
              }
            }
          }
        ), status: :ok
      end

      def available_filters
        login? # Set current user

        styles = Hash.new(0)
        climbers = {}
        routes = @spray_wall.spray_wall_routes.includes(:user, user: { avatar_attachment: :blob })

        friend_ids = []
        friend_ids = @current_user.friends.pluck(:followable_id) if @current_user

        routes.each do |route|
          if route.styles.present?
            route.styles.each do |style|
              styles[style] += 1
            end
          end
          climbers[route.user.id] ||= {
            id: route.user.id,
            full_name: route.user.full_name,
            friend: friend_ids.include?(route.user.id),
            spray_wall_routes_count: 0,
            attachments: {
              avatar: route.user.attachment_object(route.user.avatar)
            }
          }
          climbers[route.user.id][:spray_wall_routes_count] += 1
        end

        # Sort climbers by 'friends', spray_wall_routes_count, and full name
        climbers = climbers.map(&:second)
        climbers.sort_by! do |climber|
          [
            climber[:friend] ? 0 : 1,
            -climber[:spray_wall_routes_count],
            I18n.transliterate(climber[:full_name].to_s).downcase
          ]
        end

        render json: { styles: styles, climbers: climbers }, status: :ok
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
