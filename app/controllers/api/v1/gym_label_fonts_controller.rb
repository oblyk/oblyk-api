# frozen_string_literal: true

module Api
  module V1
    class GymLabelFontsController < ApiController
      def index
        render json: GymLabelFont::FONTS, status: :ok
      end
    end
  end
end
