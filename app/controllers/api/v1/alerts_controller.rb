# frozen_string_literal: true

module Api
  module V1
    class AlertsController < ApiController
      before_action :protected_by_super_admin, only: %i[create update destroy]
      before_action :set_alert, only: %i[show update destroy]

      def index
        @alerts = Alert.where(
          alertable_type: params[:alertable_type],
          alertable_id: params[:alertable_id]
        )
      end

      def show; end

      def create
        @alert = Alert.new(alert_params)
        @alert.user = @current_user
        if @alert.save
          render 'api/v1/alerts/show'
        else
          render json: { error: @alert.errors }, status: :unauthorized
        end
      end

      def update
        if @alert.update(alert_params)
          render 'api/v1/alerts/show'
        else
          render json: { error: @alert.errors }, status: :unauthorized
        end
      end

      def destroy
        if @alert.delete
          render json: {}, status: :ok
        else
          render json: { error: @alert.errors }, status: :unauthorized
        end
      end

      private

      def set_alert
        @alert = Alert.find params[:id]
      end

      def alert_params
        params.require(:alert).permit(
          :description,
          :alert_type,
          :alertable_type,
          :alertable_id
        )
      end
    end
  end
end
