# frozen_string_literal: true

module Api
  module V1
    class IndoorSubscriptionsController < ApiController
      include GymRolesVerification
      include Gymable

      before_action :set_indoor_subscription, only: %i[show update]
      before_action :user_can_manage_gym_subscription

      def index
        subscriptions = @gym.indoor_subscriptions
        render json: subscriptions.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @indoor_subscription.detail_to_json, status: :ok
      end

      def create
        # Create Or Update Gym Billing Account
        if @gym.gym_billing_account.present?
          @gym.gym_billing_account.email = create_indoor_subscription_params[:billing_account_email]
          @gym.gym_billing_account.save
        else
          gym_billing_account = GymBillingAccount.create(email: create_indoor_subscription_params[:billing_account_email])
          @gym.gym_billing_account_id = gym_billing_account.id
          @gym.save
        end

        indoor_subscription_product = IndoorSubscriptionProduct.find create_indoor_subscription_params[:indoor_subscription_product_id]

        indoor_subscription = IndoorSubscription.new(
          for_free_trial: false,
          for_gym_type: @gym.gym_type,
          month_by_occurrence: indoor_subscription_product.month_by_occurrence,
          start_date: Date.current,
          payment_status: IndoorSubscription::WAITING_FIST_PAYMENT_STATUS
        )
        indoor_subscription.gyms << @gym

        if indoor_subscription.save
          indoor_subscription.create_payment_link!(indoor_subscription_product, @gym)
          indoor_subscription.reload

          render json: indoor_subscription.detail_to_json, status: :ok
        else
          render json: { error: indoor_subscription.errors }, status: :unprocessable_entity
        end
      end

      def start_free_trial
        if IndoorSubscription.joins(:gyms).where(gyms: { id: @gym.id }).exists?
          render json: { error: { base: ['free_trial_already_exists'] } }, status: :unprocessable_entity
          return
        end

        indoor_subscription = IndoorSubscription.new(
          month_by_occurrence: 1,
          start_date: Date.current,
          for_free_trial: true,
          for_gym_type: @gym.gym_type,
          end_date: Date.current + 1.month
        )
        indoor_subscription.gyms << @gym
        if indoor_subscription.save
          indoor_subscription.update_gym_plans!

          IndoorSubscriptionMailer.with(indoor_subscription: indoor_subscription)
                                  .start_trial_period
                                  .deliver_now

          render json: indoor_subscription.detail_to_json, status: :ok
        else
          render json: { error: indoor_subscription.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @indoor_subscription.update(indoor_subscription_params)
          render json: @indoor_subscription.detail_to_json, status: :ok
        else
          render json: { error: @indoor_subscription.errors }, status: :unprocessable_entity
        end
      end

      def figures
        current_subscription = @gym.indoor_subscriptions.where('indoor_subscriptions.start_date >= :date AND (indoor_subscriptions.end_date IS NULL OR indoor_subscriptions.end_date <= :date)', date: Date.current).first
        render json: {
          end_date: current_subscription&.end_date,
          free_trial_is_available: !IndoorSubscription.joins(:gyms).where(gyms: { id: @gym.id }).exists?
        }, status: :ok
      end

      private

      def set_indoor_subscription
        @indoor_subscription = IndoorSubscription.find params[:id]
      end

      def indoor_subscription_params
        params.require(:gym).permit(
          :month_by_occurrence
        )
      end

      def create_indoor_subscription_params
        params.require(:indoor_subscription).permit(
          :indoor_subscription_product_id,
          :billing_account_email
        )
      end

      def user_can_manage_gym_subscription
        can? GymRole::MANAGE_SUBSCRIPTION if @gym.administered?
      end
    end
  end
end
