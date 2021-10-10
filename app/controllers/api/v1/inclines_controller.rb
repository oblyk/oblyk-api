# frozen_string_literal: true

module Api
  module V1
    class InclinesController < ApiController
      def index
        render json: Incline::LIST, status: :ok
      end
    end
  end
end
