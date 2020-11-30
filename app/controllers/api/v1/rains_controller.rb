# frozen_string_literal: true

module Api
  module V1
    class RainsController < ApiController
      def index
        render json: Rain::LIST
      end
    end
  end
end
