# frozen_string_literal: true

module Api
  module V1
    class LikesController < ApiController
      before_action :protected_by_session, only: %i[create destroy]
      before_action :set_like, only: %i[destroy]
      before_action :protected_by_owner, only: %i[destroy]

      def index
        likes = Like.where(
          likeable_type: params[:likeable_type],
          likeable_id: params[:likeable_id]
        )
        render json: likes.map(&:summary_to_json), status: :ok
      end

      def create
        @like = Like.find_or_initialize_by(
          likeable_type: like_params[:likeable_type],
          likeable_id: like_params[:likeable_id],
          user_id: @current_user.id
        )
        if @like.save
          render json: @like.detail_to_json, status: :ok
        else
          render json: { error: @like.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @like.blank? || @like.destroy
          render json: {}, status: :ok
        else
          render json: { error: @like.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_like
        @like = @current_user.likes.find_by likeable_type: params[:likeable_type], likeable_id: params[:likeable_id]
      end

      def like_params
        params.require(:like).permit(
          :likeable_type,
          :likeable_id
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @like.user_id
      end
    end
  end
end
