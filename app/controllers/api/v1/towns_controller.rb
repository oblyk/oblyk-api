# frozen_string_literal: true

module Api
  module V1
    class TownsController < ApiController
      before_action :set_town, only: %i[show geo_json]

      def search
        query = params[:query].parameterize
        towns = Town.where('slug_name LIKE ?', "%#{query}%").order("levenshtein(name, '#{query}')").limit(25)
        render json: towns.map(&:summary_to_json), status: :ok
      end

      def geo_search
        latitude = params[:latitude]
        longitude = params[:longitude]
        dist = params.fetch(:dist, 10)

        render json: Town.geo_search(latitude, longitude, dist).map(&:summary_to_json), status: :ok
      end

      def show
        around_dist = params.fetch(:dist, @town.default_dist)
        render json: @town.detail_to_json(around_dist), status: :ok
      end

      def geo_json
        features = []
        @town.dist_around = params.fetch(:dist, @town.default_dist)

        # Crags
        @town.crags.find_each do |crag|
          features << crag.to_geo_json
        end

        # Gyms
        @town.gyms.find_each do |gym|
          features << gym.to_geo_json
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

      def set_town
        @town = Town.find_by slug_name: params[:id]
      end
    end
  end
end
