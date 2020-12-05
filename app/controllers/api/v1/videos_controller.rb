# frozen_string_literal: true

module Api
  module V1
    class VideosController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_video, only: %i[show update destroy]

      def index
        @videos = Video.where(
          viewable_type: params[:viewable_type],
          viewable_id: params[:viewable_id]
        )
      end

      def show; end

      def create
        @video = Video.new(video_params)
        @video.user = @current_user
        if @video.save
          render 'api/v1/videos/show'
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @video.update(video_params)
          render 'api/v1/videos/show'
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @video.delete
          render json: {}, status: :ok
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_video
        @video = Video.find params[:id]
      end

      def video_params
        params.require(:video).permit(
          :viewable_type,
          :viewable_id,
          :name,
          :url,
          :description
        )
      end
    end
  end
end
