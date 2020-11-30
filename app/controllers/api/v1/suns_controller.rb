# frozen_string_literal: true

module Api
  module V1
    class SunsController < ApiController
      def index
        render json: Sun::LIST
      end
    end
  end
end
