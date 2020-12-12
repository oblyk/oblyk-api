# frozen_string_literal: true

module Api
  module V1
    class ClimbsController < ApiController
      def index
        render json: Climb::CRAG_LIST
      end
    end
  end
end
