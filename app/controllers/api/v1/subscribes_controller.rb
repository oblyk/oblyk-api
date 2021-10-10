# frozen_string_literal: true

module Api
  module V1
    class SubscribesController < ApiController
      before_action :protected_by_super_admin, only: %i[index]

      def index
        subscribes = Subscribe.all
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def create
        already_subscribe = Subscribe.find_by email: subscribe_params[:email]
        head :no_content && return if already_subscribe

        @subscribe = Subscribe.new(subscribe_params)
        if @subscribe.save
          render json: @subscribe.detail_to_json, status: :ok
        else
          render json: { error: @subscribe.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @subscribe = Subscribe.find_by email: subscribe_params[:email]
        head :no_content && return unless @subscribe

        if @subscribe&.destroy
          head :no_content
        else
          render json: { error: @subscribe.errors }, status: :unprocessable_entity
        end
      end

      private

      def subscribe_params
        params.require(:subscribe).permit(
          :email
        )
      end
    end
  end
end
