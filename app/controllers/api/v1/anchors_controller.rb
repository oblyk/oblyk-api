# frozen_string_literal: true

module Api
  module V1
    class AnchorsController < ApiController
      def index
        render json: Anchor::LIST, status: :ok
      end
    end
  end
end
