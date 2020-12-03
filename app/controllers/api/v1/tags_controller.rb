# frozen_string_literal: true

module Api
  module V1
    class TagsController < ApiController
      before_action :protected_by_session, only: %i[create destroy]
      before_action :set_tag, only: %i[destroy]

      def index
        @tags = Tag.where(
          taggable_type: params[:taggable_type],
          taggable_id: params[:taggable_id]
        )
      end

      def create
        @tag = Tag.new(tag_params)
        @tag.user = @current_user
        if @tag.save
          render 'api/v1/tags/show'
        else
          render json: { error: @tag.errors }, status: :unauthorized
        end
      end

      def destroy
        if @tag.delete
          render json: {}, status: :ok
        else
          render json: { error: @tag.errors }, status: :unauthorized
        end
      end

      private

      def set_tag
        @tag = Tag.find params[:id]
      end

      def tag_params
        params.require(:tag).permit(
          :taggable_type,
          :taggable_id,
          :name
        )
      end
    end
  end
end
