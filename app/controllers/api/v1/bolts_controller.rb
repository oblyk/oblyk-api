# frozen_string_literal: true

module Api
  module V1
    class BoltsController < ApiController
      def index
        render json: Bolt::LIST, status: :ok
      end
    end
  end
end
