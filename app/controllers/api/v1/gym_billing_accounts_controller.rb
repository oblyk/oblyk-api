# frozen_string_literal: true

module Api
  module V1
    class GymBillingAccountsController < ApiController
      include Gymable
      before_action -> { can? GymRole::MANAGE_SUBSCRIPTION }
      before_action :set_gym_billing_account, only: %i[show update]

      def show
        render json: @gym_billing_account.detail_to_json, status: :ok
      end

      def create
        gym_billing_account = GymBillingAccount.new(gym_billing_account_params)
        if gym_billing_account.save
          @gym.gym_billing_account = gym_billing_account
          @gym.save!
          render json: gym_billing_account.detail_to_json, status: :ok
        else
          render json: gym_billing_account.errors, status: :unprocessable_entity
        end
      end

      def update
        if @gym_billing_account.update(gym_billing_account_params)
          render json: @gym_billing_account.detail_to_json, status: :ok
        else
          render json: @gym_billing_account.errors, status: :unprocessable_entity
        end
      end

      private

      def set_gym_billing_account
        @gym_billing_account = GymBillingAccount.find params[:id]
      end

      def gym_billing_account_params
        params.require(:gym_billing_account).permit(
          :name,
          :email,
          :phone,
          :siret,
          :address_line1,
          :address_line2,
          :city,
          :postal_code,
          :country_code,
          :state
        )
      end
    end
  end
end
