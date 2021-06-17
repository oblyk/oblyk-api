# frozen_string_literal: true

module Api
  module V1
    class SearchesController < ApiController
      def index
        query = params.fetch(:query, nil)
        return unless query

        results = {
          crags: Crag.search(query).map(&:summary_to_json),
          gyms: Gym.search(query).map(&:summary_to_json),
          guide_book_papers: GuideBookPaper.search(query).map(&:summary_to_json),
          users: User.search(query).map(&:summary_to_json),
          crag_routes: CragRoute.search(query).map(&:summary_to_json),
          words: Word.search(query).map(&:summary_to_json),
          areas: Area.search(query).map(&:summary_to_json)
        }

        render json: results
      end
    end
  end
end
