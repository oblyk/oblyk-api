# frozen_string_literal: true

module Api
  module V1
    class RainsController < ApiController
      def index
        render json: Rain::LIST, status: :ok
      end
    end
  end
end
