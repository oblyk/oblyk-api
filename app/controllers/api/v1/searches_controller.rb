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
    end
  end
end
