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
    end
  end
end
