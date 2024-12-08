# frozen_string_literal: true

module Api
  module V1
    class CommentsController < ApiController
      before_action :protected_by_session, only: %i[create update destroy moderate_by_gym_administrator]
      before_action :set_comment, only: %i[show comments update destroy moderate_by_gym_administrator]
      before_action :protected_by_owner, only: %i[update destroy moderate_by_gym_administrator]

      def index
        comments = Comment.where(
          commentable_type: params[:commentable_type],
          commentable_id: params[:commentable_id]
        )
        render json: comments.map(&:summary_to_json), status: :ok
      end

      def comments
        page = params.fetch(:page, 1)
        comments = Comment.where(commentable_type: 'Comment', commentable_id: @comment.id)
                          .order(created_at: :asc)
                          .page(page)
                          .per(5)
        render json: comments.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @comment.detail_to_json, status: :ok
      end

      def create
        @comment = Comment.new(comment_params)
        @comment.user = @current_user
        if @comment.save
          render json: @comment.detail_to_json, status: :ok
        else
          render json: { error: @comment.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @comment.update(comment_params)
          render json: @comment.detail_to_json, status: :ok
        else
          render json: { error: @comment.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @comment.destroy
          render json: {}, status: :ok
        else
          render json: { error: @comment.errors }, status: :unprocessable_entity
        end
      end

      def moderate_by_gym_administrator
        gym_ids = @current_user.gym_administrators&.pluck(:gym_id)

        unless gym_ids
          render forbidden
          return
        end

        authorize = false
        type = @comment.commentable_type
        commentable = @comment.commentable

        authorize = true if type == 'GymRoute' && gym_ids.include?(commentable.gym_sector.gym_space.gym_id)
        authorize = true if type == 'Ascent' && gym_ids.include?(commentable.gym_id)

        if type == 'Comment'
          authorize = true if commentable.commentable_type == 'GymRoute' && gym_ids.include?(commentable.commentable.gym_sector.gym_space.gym_id)
          authorize = true if commentable.commentable_type == 'Ascent' && gym_ids.include?(commentable.commentable.gym_id)
          authorize = true if commentable.commentable_type == 'Comment' && commentable.commentable.commentable_type == 'Ascent' && gym_ids.include?(commentable.commentable.commentable.gym_id)
          authorize = true if commentable.commentable_type == 'Comment' && commentable.commentable.commentable_type == 'GymRoute' && gym_ids.include?(commentable.commentable.commentable.gym_sector.gym_space.gym_id)
        end

        unless authorize
          render forbidden
          return
        end

        @comment.moderated_at = DateTime.now
        if @comment.save
          head :no_content
        else
          render json: { error: @comment.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_comment
        @comment = Comment.find params[:id]
      end

      def comment_params
        params.require(:comment).permit(
          :commentable_type,
          :commentable_id,
          :reply_to_comment_id,
          :body
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @comment.user_id
      end
    end
  end
end
