# frozen_string_literal: true

module Api
  module V1
    class GuideBookWebsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_guide_book_web, only: %i[show update destroy]

      def index
        @guide_book_webs = GuideBookWeb.where crag_id: params[:crag_id]
      end

      def show; end

      def create
        @guide_book_web = GuideBookWeb.new(guide_book_web_params)
        @guide_book_web.user = @current_user
        if @guide_book_web.save
          render 'api/v1/guide_book_webs/show'
        else
          render json: { error: @guide_book_web.errors }, status: :unauthorized
        end
      end

      def update
        if @guide_book_web.update(guide_book_web_params)
          render 'api/v1/guide_book_webs/show'
        else
          render json: { error: @guide_book_web.errors }, status: :unauthorized
        end
      end

      def destroy
        if @guide_book_web.delete
          render json: {}, status: :ok
        else
          render json: { error: @guide_book_web.errors }, status: :unauthorized
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
