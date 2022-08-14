# frozen_string_literal: true

module Api
  module V1
    class CommonsController < ApiController
      def figures
        last_date = DateTime.now - 1.day
        render json: {
          all: {
            crags_count: Crag.count,
            users_count: User.count,
            gyms_count: Gym.count,
            routes_count: GymRoute.count + CragRoute.count,
            ascents_count: Ascent.count,
            photos_count: Photo.count,
            guides_count: GuideBookPaper.count + GuideBookPdf.count + GuideBookWeb.count,
            comments_count: Comment.count + Ascent.where.not(comment: nil).where(private_comment: false).count,
            videos_count: Video.count
          },
          latest: {
            crags_count: Crag.where('created_at >= ?', last_date).count,
            users_count: User.where('created_at >= ?', last_date).count,
            gyms_count: Gym.where('created_at >= ?', last_date).count,
            routes_count: GymRoute.where('created_at >= ?', last_date).count + CragRoute.where('created_at >= ?', last_date).count,
            ascents_count: Ascent.where('created_at >= ?', last_date).count,
            photos_count: Photo.where('created_at >= ?', last_date).count,
            guides_count: GuideBookPaper.where('created_at >= ?', last_date).count + GuideBookPdf.where('created_at >= ?', last_date).count + GuideBookWeb.where('created_at >= ?', last_date).count,
            comments_count: Comment.where('created_at >= ?', last_date).count + Ascent.where.not(comment: nil).where(private_comment: false).where('created_at >= ?', last_date).count,
            videos_count: Video.where('created_at >= ?', last_date).count
          }
        }, status: :ok
      end

      def last_activity_feed
        feeds = Feed.where(feedable_type: %w[Crag Gym GuideBookPaper])
                    .order(posted_at: :desc)
                    .page(params.fetch(:page, 1))
        render json: feeds, status: :ok
      end
    end
  end
end
