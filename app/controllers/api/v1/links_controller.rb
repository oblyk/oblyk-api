# frozen_string_literal: true

module Api
  module V1
    class LinksController < ApiController
      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_link, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        links = Link.includes(:user).where(
          linkable_type: params[:linkable_type],
          linkable_id: params[:linkable_id]
        )
        render json: links.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @link.detail_to_json, status: :ok
      end

      def create
        @link = Link.new(link_params)
        @link.user = @current_user
        if @link.save
          render json: @link.detail_to_json, status: :ok
        else
          render json: { error: @link.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @link.update(link_params)
          render json: @link.detail_to_json, status: :ok
        else
          render json: { error: @link.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @link.destroy
          render json: {}, status: :ok
        else
          render json: { error: @link.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_link
        @link = Link.find params[:id]
      end

      def link_params
        params.require(:link).permit(
          :linkable_type,
          :linkable_id,
          :name,
          :url,
          :description
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @link.user_id
      end
    end
  end
end
