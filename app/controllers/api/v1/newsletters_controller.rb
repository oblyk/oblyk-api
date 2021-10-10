# frozen_string_literal: true

module Api
  module V1
    class NewslettersController < ApiController
      before_action :protected_by_super_admin, except: %i[show]
      before_action :set_newsletter, only: %i[show photos update send_newsletter destroy]

      def index
        newsletters = Newsletter.order(created_at: :desc)
        render json: newsletters.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @newsletter.detail_to_json, status: :ok
      end

      def photos
        photos = @newsletter.photos
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def create
        @newsletter = Newsletter.new(newsletter_params)
        if @newsletter.save
          render json: @newsletter.detail_to_json, status: :ok
        else
          render json: { error: @newsletter.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @newsletter.update(newsletter_params)
          render json: @newsletter.detail_to_json, status: :ok
        else
          render json: { error: @newsletter.errors }, status: :unprocessable_entity
        end
      end

      def send_newsletter
        @newsletter.send_newsletter!
        head :no_content
      end

      def destroy
        if @newsletter.destroy
          render json: {}, status: :ok
        else
          render json: { error: @newsletter.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_newsletter
        @newsletter = Newsletter.find params[:id]
      end

      def newsletter_params
        params.require(:newsletter).permit(
          :name,
          :body
        )
      end
    end
  end
end
