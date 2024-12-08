# frozen_string_literal: true

module Api
  module V1
    class VideosController < ApiController
      before_action :protected_by_session, only: %i[create update destroy moderate_by_gym_administrator]
      before_action :set_video, only: %i[show update destroy moderate_by_gym_administrator]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        videos = Video.where(
          viewable_type: params[:viewable_type],
          viewable_id: params[:viewable_id]
        ).order(created_at: :desc)
        render json: videos.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @video.detail_to_json, status: :ok
      end

      def create
        @video = Video.new(video_params)
        @video.user = @current_user
        if @video.save
          render json: @video.detail_to_json, status: :ok
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @video.update(video_params)
          render json: @video.detail_to_json, status: :ok
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @video.destroy
          render json: {}, status: :ok
        else
          render json: { error: @video.errors }, status: :unprocessable_entity
        end
      end

      def moderate_by_gym_administrator
        gym_ids = @current_user.gym_administrators&.pluck(:gym_id)
        unless gym_ids
          render forbidden
          return
        end

        if @video.viewable_type == 'GymRoute' && gym_ids.include?(@video.viewable.gym_sector.gym_space.gym_id)
          @video.destroy
          head :no_content
        else
          render forbidden
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

      def protected_by_owner
        forbidden if @current_user.id != @video.user_id
      end
    end
  end
end
