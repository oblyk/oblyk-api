# frozen_string_literal: true

module Api
  module V1
    class SearchesController < ApiController
      def index
        query = params.fetch(:query, nil)
        return unless query

        results = {
          crags: Crag.includes(photo: { picture_attachment: :blob }).search(query).map(&:summary_to_json),
          gyms: Gym.includes(banner_attachment: :blob, logo_attachment: :blob).search(query).map(&:summary_to_json),
          guide_book_papers: GuideBookPaper.includes(cover_attachment: :blob).search(query).map(&:summary_to_json),
          users: User.includes(avatar_attachment: :blob).search(query, exact_name: true).map(&:summary_to_json),
          crag_routes: CragRoute.includes(crag_sector: { photo: { picture_attachment: :blob } }, crag: { photo: { picture_attachment: :blob } }, photo: { picture_attachment: :blob }).search(query, exact_name: true).map { |crag_route| crag_route.summary_to_json(with_crag_in_sector: false) },
          words: Word.search(query).map(&:summary_to_json),
          areas: Area.includes(photo: { picture_attachment: :blob }).search(query).map(&:summary_to_json)
        }

        render json: results, status: :ok
      end

      def search_all
        query = params.fetch(:query, nil)
        return unless query

        page = params.fetch(:page, 1).to_i
        collections = params.fetch(:collections, nil)
        results = Search.infinite_search query, collections, page

        return unless results

        # Create groupe by collection
        result_by_objects = {}
        results.map { |result| result[:collection] }.each do |result_collection|
          result_by_objects[result_collection] = results.filter { |result| result[:collection] == result_collection }.map { |el| el[:index_id] }
        end

        # Get data by type
        result_by_objects = {
          Crag: result_by_objects[:Crag].present? ? Crag.includes(photo: { picture_attachment: :blob }).where(id: result_by_objects[:Crag]).map(&:summary_to_json) : [],
          CragRoute: result_by_objects[:CragRoute].present? ? CragRoute.includes(photo: { picture_attachment: :blob }).where(id: result_by_objects[:CragRoute]).map { |crag_route| crag_route.summary_to_json(with_crag_in_sector: false) } : [],
          Gym: result_by_objects[:Gym].present? ? Gym.includes(banner_attachment: :blob, logo_attachment: :blob).where(id: result_by_objects[:Gym]).map(&:summary_to_json) : [],
          GuideBookPaper: result_by_objects[:GuideBookPaper].present? ? GuideBookPaper.includes(cover_attachment: :blob).where(id: result_by_objects[:GuideBookPaper]).map(&:summary_to_json) : [],
          User: result_by_objects[:User].present? ? User.includes(avatar_attachment: :blob).where(id: result_by_objects[:User]).map(&:summary_to_json) : [],
          Word: result_by_objects[:Word].present? ? Word.where(id: result_by_objects[:Word]).map(&:summary_to_json) : [],
          Area: result_by_objects[:Area].present? ? Area.includes(photo: { picture_attachment: :blob }).where(id: result_by_objects[:Area]).map(&:summary_to_json) : []
        }

        # re-map data on results
        remap_results = []
        results.each do |result|
          remap_results << {
            result_type: result[:collection],
            result_object: result_by_objects[result[:collection]].find { |el| el[:id] == result[:index_id] }
          }
        end

        render json: {
          query: query,
          page: page,
          results: remap_results
        }, status: :ok
      end

      def search_around
        latitude = params.fetch(:latitude, nil)
        longitude = params.fetch(:longitude, nil)
        page = params.fetch(:page, 1).to_i
        query = ActiveRecord::Base.sanitize_sql(
          [
            "SELECT id,
                    type,
                    getrange(latitude, longitude, :latitude, :longitude)
             FROM (SELECT id, 'Crag' AS type, name, latitude, longitude
                   FROM crags
                   WHERE deleted_at IS NULL
                   UNION ALL
                   SELECT id, 'Gym' AS type, name, latitude, longitude
                   FROM gyms
                   WHERE deleted_at IS NULL) AS crag_and_gyms
             ORDER BY getrange(latitude, longitude, :latitude, :longitude)
             LIMIT 25 OFFSET :page",
            {
              latitude: latitude,
              longitude: longitude,
              page: (page - 1) * 25
            }
          ]
        )
        crag_and_gyms = ActiveRecord::Base.connection.execute(query)
        results = crag_and_gyms.to_a.map do |crag_and_gym|
          {
            id: crag_and_gym[0],
            type: crag_and_gym[1],
            distance: crag_and_gym[2]
          }
        end
        crags = Crag.where(id: results.filter { |el| el[:type] == 'Crag' }.map { |el| el[:id] }).map(&:summary_to_json)
        gyms = Gym.where(id: results.filter { |el| el[:type] == 'Gym' }.map { |el| el[:id] }).map(&:summary_to_json)
        data = []
        results.each do |result|
          if result[:type] == 'Crag'
            data << {
              type: :Crag,
              data: crags.find { |crag| crag[:id] == result[:id] }
            }
          end
          next unless result[:type] == 'Gym'

          data << {
            type: :Gym,
            data: gyms.find { |gym| gym[:id] == result[:id] }
          }
        end
        render json: data, status: :ok
      end
    end
  end
end
