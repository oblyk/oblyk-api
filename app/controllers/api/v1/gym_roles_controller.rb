# frozen_string_literal: true

module Api
  module V1
    class GymRolesController < ApiController
      def index
        render json: GymRole::LIST, status: :ok
      end
    end
  end
end
