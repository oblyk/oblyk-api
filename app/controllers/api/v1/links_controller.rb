# frozen_string_literal: true

module Api
  module V1
    class LinksController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_link, only: %i[show update destroy]

      def index
        @links = Link.where(
          linkable_type: params[:linkable_type],
          linkable_id: params[:linkable_id]
        )
      end

      def show; end

      def create
        @link = Link.new(link_params)
        @link.user = @current_user
        if @link.save
          render 'api/v1/links/show'
        else
          render json: { error: @link.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @link.update(link_params)
          render 'api/v1/links/show'
        else
          render json: { error: @link.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @link.delete
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
    end
  end
end
