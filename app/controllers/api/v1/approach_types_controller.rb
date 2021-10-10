# frozen_string_literal: true

module Api
  module V1
    class ApproachTypesController < ApiController
      def index
        render json: Approach::STYLES_LIST, status: :ok
      end
    end
  end
end
