# frozen_string_literal: true

module Api
  module V1
    class ClimbsController < ApiController
      def index
        render json: Climb::LIST
      end
    end
  end
end
