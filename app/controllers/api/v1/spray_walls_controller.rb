# frozen_string_literal: true

module Api
  module V1
    class SprayWallsController < ApiController
      include Gymable

      skip_before_action :protected_by_session, only: %i[index show]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_spray_wall, except: %i[index create]
      before_action -> { can? GymRole::MANAGE_OPENING }, except: %i[index show]

      def index
        render json: serializer(
          SprayWallSerializer,
          @gym.spray_walls.includes(picture_attachment: :blob),
          { params: { include_attachments: { SprayWall: %i[picture] } } }
        ), status: :ok
      end

      def show
        render json: serializer(
          SprayWallSerializer,
          @spray_wall,
          {
            include: %i[spray_wall_holds],
            params: { include_attachments: { SprayWall: %i[picture] } }
          }
        ), status: :ok
      end

      def create
        spray_wall = SprayWall.new(spray_wall_params)
        spray_wall.gym = @gym
        if spray_wall.save
          spray_wall.set_picture_dimension!
          spray_wall = SprayWall.includes(picture_attachment: :blob).find(spray_wall.id)
          render json: serializer(
            SprayWallSerializer,
            spray_wall,
            { params: { include_attachments: { SprayWall: %i[picture] } } }
          ), status: :ok
        else
          render json: { error: spray_wall.errors }, status: :unprocessable_content
        end
      end

      def update
        if @spray_wall.update(spray_wall_params)
          render json: serializer(
            SprayWallSerializer,
            @spray_wall,
            { params: { include_attachments: { SprayWall: %i[picture] } } }
          ), status: :ok
        else
          render json: { error: @spray_wall.errors }, status: :unprocessable_content
        end
      end

      def destroy
        if @spray_wall.destroy
          head :no_content
        else
          render json: { error: @spray_wall.errors }, status: :unprocessable_content
        end
      end

      def add_picture
        return unless verify_file picture_params[:picture], :image

        params[:spray_wall][:picture] = convert_image_on_params %i[spray_wall picture]
        @spray_wall.update picture_params
        head :no_content
      end

      def archive
        @spray_wall.archive!
        head :no_content
      end

      def unarchive
        @spray_wall.unarchive!
        head :no_content
      end

      private

      def set_spray_wall
        @spray_wall = @gym.spray_walls.includes(picture_attachment: :blob).find params[:id]
      end

      def spray_wall_params
        params.require(:spray_wall).permit(
          :name,
          :gym_sector_id,
          :gym_space_id,
          :picture
        )
      end

      def picture_params
        params.require(:spray_wall).permit(
          :picture
        )
      end
    end
  end
end
