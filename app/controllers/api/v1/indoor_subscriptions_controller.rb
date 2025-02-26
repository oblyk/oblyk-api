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

        trial_end_date = nil
        number_of_trials_days = nil
        if @gym.indoor_subscriptions.count.zero?
          number_of_trials_days = 28
          trial_end_date = Date.current + number_of_trials_days
        end

        indoor_subscription = IndoorSubscription.new(
          for_gym_type: @gym.gym_type,
          month_by_occurrence: indoor_subscription_product.month_by_occurrence,
          start_date: Date.current,
          trial_end_date: trial_end_date,
          payment_status: IndoorSubscription::WAITING_FIST_PAYMENT_STATUS
        )
        indoor_subscription.gyms << @gym

        if indoor_subscription.save
          indoor_subscription.create_payment_link!(indoor_subscription_product, @gym, number_of_trials_days)
          indoor_subscription.reload

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
