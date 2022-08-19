# frozen_string_literal: true

module Api
  module V1
    class TownsController < ApiController
      before_action :set_town, only: %i[show geo_json]

      def search
        query = params[:query].parameterize
        like_ngram = Search.ngram_splitter(query, 4).map { |word| "`slug_name` LIKE '%#{word}%'" }.join(' OR ')
        towns = Town.includes(department: :country).where(like_ngram)

        levenshtein_results = []
        towns.each do |town|
          levenshtein_score = Levenshtein.distance(town.slug_name, query)

          levenshtein_results << { town: town, levenshtein_score: levenshtein_score }
        end

        levenshtein_results.sort_by! { |levenshtein_result| levenshtein_result[:levenshtein_score] }
        results = []
        levenshtein_results.each_with_index do |levenshtein_result, index|
          results << levenshtein_result[:town].summary_to_json
          break if index > 24
        end

        render json: results, status: :ok
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
        @town.crags.includes(photo: { picture_attachment: :blob }).find_each do |crag|
          features << crag.to_geo_json
        end

        # Gyms
        @town.gyms.includes(banner_attachment: :blob).find_each do |gym|
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
