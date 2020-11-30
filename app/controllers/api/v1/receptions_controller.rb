# frozen_string_literal: true

module Api
  module V1
    class ReceptionsController < ApiController
      def index
        render json: Reception::LIST
      end
    end
  end
end
