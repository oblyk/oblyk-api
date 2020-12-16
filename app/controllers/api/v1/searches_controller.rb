# frozen_string_literal: true

module Api
  module V1
    class SearchesController < ApiController
      def index
        render json: Search::OblykSearch.call(params[:query])
      end
    end
  end
end
