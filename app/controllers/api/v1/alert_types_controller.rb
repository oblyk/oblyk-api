# frozen_string_literal: true

module Api
  module V1
    class AlertTypesController < ApiController
      def index
        render json: Alert::ALERT_TYPES_LIST
      end
    end
  end
end
