# frozen_string_literal: true

module Api
  module V1
    class IndoorSubscriptionProductsController < ApiController
      before_action :set_indoor_subscription_product, only: %i[show]

      def index
        gym = Gym.find(params[:gym_id])
        products = IndoorSubscriptionProduct.where(for_gym_type: gym.gym_type)
                                            .order(:order)
        render json: products.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @indoor_subscription_product.detail_to_json, status: :ok
      end

      private

      def set_indoor_subscription_product
        @indoor_subscription_product = IndoorSubscriptionProduct.find params[:id]
      end
    end
  end
end
