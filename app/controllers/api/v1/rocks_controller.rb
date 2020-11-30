# frozen_string_literal: true

module Api
  module V1
    class RocksController < ApiController
      def index
        render json: Rock::LIST
      end
    end
  end
end
