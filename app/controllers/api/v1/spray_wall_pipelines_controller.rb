# frozen_string_literal: true

module Api
  module V1
    class SprayWallPipelinesController < ApiController
      include Gymable

      before_action :protected_by_session
      before_action :protected_by_gym_administrator
      before_action :set_spray_wall
      before_action :set_spray_wall_pipeline, only: %i[show]
      before_action -> { can? GymRole::MANAGE_OPENING }

      def index
        render json: serializer(
          SprayWallPipelineSerializer,
          @spray_wall.spray_wall_pipelines
        ), status: :ok
      end

      def show
        render json: serializer(
          SprayWallPipelineSerializer,
          @spray_wall_pipeline,
          {
            include: %i[spray_wall_holds],
            params: { include_attachments: { SprayWall: %i[picture] } }
          }
        ), status: :ok
      end

      def create
        spray_wall_pipeline = SprayWallPipeline.new
        spray_wall_pipeline.status = "initialised"
        spray_wall_pipeline.service = "roboflow"
        spray_wall_pipeline.spray_wall = @spray_wall
        if spray_wall_pipeline.save
          spray_wall_pipeline.run!
          render json: serializer(
            SprayWallPipelineSerializer,
            spray_wall_pipeline
          ), status: :ok
        else
          render json: { error: spray_wall_pipeline.errors }, status: :unprocessable_content
        end
      end

      private

      def set_spray_wall
        @spray_wall = @gym.spray_walls.includes(picture_attachment: :blob).find params[:spray_wall_id]
      end

      def set_spray_wall_pipeline
        @spray_wall_pipeline = @spray_wall.spray_wall_pipelines.find params[:id]
      end
    end
  end
end
