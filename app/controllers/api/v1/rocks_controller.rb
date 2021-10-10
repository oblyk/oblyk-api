# frozen_string_literal: true

module Api
  module V1
    class RocksController < ApiController
      def index
        render json: Rock::LIST, status: :ok
      end
    end
  end
end
