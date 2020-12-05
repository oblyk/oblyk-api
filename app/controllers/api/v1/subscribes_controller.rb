# frozen_string_literal: true

module Api
  module V1
    class SubscribesController < ApiController
      before_action :protected_by_super_admin, only: %i[index]

      def index
        @subscribes = Subscribe.all
      end

      def create
        @subscribe = Subscribe.new(subscribe_params)
        if @subscribe.save
          render 'api/v1/subscribes/show'
        else
          render json: { error: @subscribe.errors }, status: :unprocessable_entity
        end
      end

      def unsubscribe
        @subscribe = Subscribe.find_by email: subscribe_params[:email]
        if @subscribe.delete
          render json: {}, status: :ok
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
