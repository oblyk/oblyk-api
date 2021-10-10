# frozen_string_literal: true

module Api
  module V1
    class StartsController < ApiController
      def index
        render json: Start::LIST, status: :ok
      end
    end
  end
end
