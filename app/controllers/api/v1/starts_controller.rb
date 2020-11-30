# frozen_string_literal: true

module Api
  module V1
    class StartsController < ApiController
      def index
        render json: Start::LIST
      end
    end
  end
end
