# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :set_user
      before_action :protected_private_profile
      before_action :protected_outdoor_log_book, only: %i[outdoor_figures outdoor_climb_types_chart ascended_crag_routes outdoor_grades_chart]

      def show; end

      def photos
        @photos = @user.photos
        render 'api/v1/photos/index'
      end

      def videos
        @videos = @user.videos
        render 'api/v1/videos/index'
      end

      def contribution
        render json: {
          crags_count: Crag.where(user: @user).count,
          gyms_count: Gym.where(user: @user).count,
          routes_count: CragRoute.where(user: @user).count,
          photos_count: Photo.where(user: @user).count,
          videos_count: Video.where(user: @user).count,
          guides_count: GuideBookPaper.where(user: @user).count + GuideBookPdf.where(user: @user).count + GuideBookWeb.where(user: @user).count,
          comments_count: Comment.where(user: @user).count + Ascent.where.not(comment: nil).where(private_comment: false).where(user: @user).count
        }, status: :ok
      end

      def outdoor_figures
        render json: LogBook::Outdoor::Figure.new(@user).figures, status: :ok
      end

      def outdoor_climb_types_chart
        render json: LogBook::Outdoor::Chart.new(@user).climb_type, status: :ok
      end

      def ascended_crag_routes
        crag_route_ids = @user.ascent_crag_routes.made.pluck(:crag_route_id)
        @crag_routes = case params[:order]
                       when 'crags'
                         CragRoute.where(id: crag_route_ids).joins(:crag).order('crags.name')
                       when 'released_at'
                         CragRoute.where(id: crag_route_ids).order(released_at: :desc)
                       else
                         CragRoute.where(id: crag_route_ids).order(max_grade_value: :desc)
                       end
        render 'api/v1/crag_routes/index'
      end

      def outdoor_grades_chart
        render json: LogBook::Outdoor::Chart.new(@user).grade, status: :ok
      end

      def partner_user_geo_json
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: [
            @user.to_partner_geo_json
          ]
        }, status: :ok
      end

      private

      def protected_private_profile
        return if @user.public_profile
        return if login?

        render json: {}, status: :unauthorized
      end

      def protected_outdoor_log_book
        return if @user.public_profile && @user.public_outdoor_ascents
        return if login? && @user.public_outdoor_ascents

        render json: {}, status: :unauthorized
      end

      def set_user
        @user = User.find_by uuid: params[:id]
      end
    end
  end
end
