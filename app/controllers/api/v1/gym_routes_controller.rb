# frozen_string_literal: true

module Api
  module V1
    class GymRoutesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space, except: %i[add_picture add_thumbnail dismount mount]
      before_action :set_gym_sector, except: %i[index show add_picture add_thumbnail dismount mount]
      before_action :set_gym_route, only: %i[show update destroy add_picture add_thumbnail dismount mount]

      def index
        routes = if @gym_sector.present?
                   GymRoute.where(gym_sector: @gym_sector)
                 elsif @gym_space.present?
                   GymRoute.joins(:gym_sector).where(gym_sectors: { gym_space: @gym_space })
                 else
                   GymRoute.where(gym: @gym)
                 end
        dismounted = params.fetch(:dismounted, false)
        @gym_routes = if dismounted
                        routes.dismounted
                      else
                        routes.mounted
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

      def add_picture
        if @gym_route.update(picture_params)
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_thumbnail
        if @gym_route.update(thumbnail_params)
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

      def dismount
        if @gym_route.dismount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def mount
        if @gym_route.mount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space
        @gym_space = GymSpace.find params[:gym_space_id]
      end

      def set_gym_sector
        @gym_sector = GymSector.find params[:gym_sector_id]
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
          :points,
          :opened_at,
          sections: [:climbing_type, :description, :grade, :height, { tags: [] }],
          hold_colors: %i[],
          tag_colors: %i[]
        )
      end

      def picture_params
        params.require(:gym_route).permit(
          :picture
        )
      end

      def thumbnail_params
        params.require(:gym_route).permit(
          :thumbnail
        )
      end
    end
  end
end
