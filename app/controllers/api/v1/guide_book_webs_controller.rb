# frozen_string_literal: true

module Api
  module V1
    class GuideBookWebsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_guide_book_web, only: %i[show update destroy]

      def index
        guide_book_webs = GuideBookWeb.where crag_id: params[:crag_id]
        render json: guide_book_webs.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @guide_book_web.detail_to_json, status: :ok
      end

      def create
        @guide_book_web = GuideBookWeb.new(guide_book_web_params)
        @guide_book_web.user = @current_user
        if @guide_book_web.save
          render json: @guide_book_web.detail_to_json, status: :ok
        else
          render json: { error: @guide_book_web.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @guide_book_web.update(guide_book_web_params)
          render json: @guide_book_web.detail_to_json, status: :ok
        else
          render json: { error: @guide_book_web.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @guide_book_web.destroy
          render json: {}, status: :ok
        else
          render json: { error: @guide_book_web.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_guide_book_web
        @guide_book_web = GuideBookWeb.find params[:id]
      end

      def guide_book_web_params
        params.require(:guide_book_web).permit(
          :name,
          :url,
          :publication_year,
          :crag_id
        )
      end
    end
  end
end
