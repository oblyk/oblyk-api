# frozen_string_literal: true

module Api
  module V1
    class ClimbingStylesController < ApiController
      def index
        render json: ClimbingStyle::STYLE_LIST, status: :ok
      end
    end
  end
end
