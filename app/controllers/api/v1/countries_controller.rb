# frozen_string_literal: true

module Api
  module V1
    class CountriesController < ApiController
      before_action :set_countries, only: %i[show geo_json route_figures]

      def index
        render json: Country.all.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @country.detail_to_json, status: :ok
      end

      def route_figures
        render json: @country.route_figures, status: :ok
      end

      def geo_json
        features = []

        # Departments
        @country.departments.find_each do |department|
          features << department.to_geo_json if department.geo_polygon
        end

        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: features
        }, status: :ok
      end

      private

      def set_countries
        @country = Country.find_by code_country: params[:id]
      end
    end
  end
end
