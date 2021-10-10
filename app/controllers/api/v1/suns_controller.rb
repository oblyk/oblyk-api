# frozen_string_literal: true

module Api
  module V1
    class SunsController < ApiController
      def index
        render json: Sun::LIST, status: :ok
      end
    end
  end
end
