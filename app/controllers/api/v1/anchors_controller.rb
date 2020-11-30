# frozen_string_literal: true

module Api
  module V1
    class AnchorsController < ApiController
      def index
        render json: Anchor::LIST
      end
    end
  end
end
