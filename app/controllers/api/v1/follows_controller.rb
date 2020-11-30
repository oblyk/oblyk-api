# frozen_string_literal: true

module Api
  module V1
    class FollowsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_follow, only: %i[show update destroy]

      def index
        @follows = Follow.where(
          followable_type: params[:followable_type],
          followable_id: params[:followable_id]
        )
      end

      def show; end

      def create
        @follow = Follow.new(follow_params)
        @follow.user = @current_user
        if @follow.save
          render 'api/v1/follows/show'
        else
          render json: { error: @follow.errors }, status: :unauthorized
        end
      end

      def update
        if @follow.update(follow_params)
          render 'api/v1/follows/show'
        else
          render json: { error: @follow.errors }, status: :unauthorized
        end
      end

      def destroy
        if @follow.delete
          render json: {}, status: :ok
        else
          render json: { error: @follow.errors }, status: :unauthorized
        end
      end

      private

      def set_follow
        @follow = Follow.find params[:id]
      end

      def follow_params
        params.require(:follow).permit(
          :followable_type,
          :followable_id
        )
      end
    end
  end
end
