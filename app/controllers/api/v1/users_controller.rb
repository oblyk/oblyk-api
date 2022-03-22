# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :protected_by_session, only: %i[search]
      before_action :set_user, except: %i[search]
      before_action :protected_private_profile, except: %i[search]
      before_action :protected_media, only: %i[photos videos]
      before_action :protected_outdoor_log_book, only: %i[outdoor_figures outdoor_climb_types_chart ascended_crag_routes outdoor_grades_chart]

      def show
        render json: @user.detail_to_json, status: :ok
      end

      def search
        query = params[:query]
        users = User.search(query)
        render json: users.map(&:summary_to_json), status: :ok
      end

      def subscribes
        page = params.fetch(:page, 1)
        subscribes = @user.subscribes.accepted.order(views: :desc).page(page)
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def followers
        users = []
        page = params.fetch(:page, 1)
        followers = @user.follows.order(created_at: :desc).page(page)
        followers.each do |follower|
          users << follower.user.summary_to_json
        end
        render json: users, status: :ok
      end

      def photos
        page = params.fetch(:page, 1)
        photos = @user.photos.order(posted_at: :desc).page(page)
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def videos
        page = params.fetch(:page, 1)
        videos = @user.videos.order(created_at: :desc).page(page)
        render json: videos.map(&:summary_to_json), status: :ok
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
        page = params.fetch(:page, 1)
        climbing_type_filter = params.fetch(:climbing_type, 'all')
        climbing_filters = []
        climbing_filters << 'sport_climbing' if %w[sport_climbing all].include?(climbing_type_filter)
        climbing_filters << 'bouldering' if %w[bouldering all].include?(climbing_type_filter)
        climbing_filters << 'multi_pitch' if %w[multi_pitch all].include?(climbing_type_filter)
        climbing_filters << 'trad_climbing' if %w[trad_climbing all].include?(climbing_type_filter)
        climbing_filters << 'aid_climbing' if %w[aid_climbing all].include?(climbing_type_filter)
        climbing_filters << 'deep_water' if %w[deep_water all].include?(climbing_type_filter)
        climbing_filters << 'via_ferrata' if %w[via_ferrata all].include?(climbing_type_filter)

        @crag_routes = case params[:order]
                       when 'crags'
                         CragRoute.includes(:crag, :crag_sector)
                                  .where(id: crag_route_ids)
                                  .where(climbing_type: climbing_filters)
                                  .joins(:crag)
                                  .order('crags.name, crag_routes.name, crag_routes.id')
                                  .page(page)
                       when 'released_at'
                         CragRoute.joins("INNER JOIN ascents ON ascents.crag_route_id = crag_routes.id AND ascents.type = 'AscentCragRoute' AND ascents.user_id = #{@user.id}")
                                  .includes(:crag, :crag_sector)
                                  .where(climbing_type: climbing_filters)
                                  .where(id: crag_route_ids)
                                  .order('ascents.released_at DESC, crag_routes.name, crag_routes.id')
                                  .page(page)
                       else
                         CragRoute.includes(:crag, :crag_sector)
                                  .where(id: crag_route_ids)
                                  .where(climbing_type: climbing_filters)
                                  .order('crag_routes.max_grade_value DESC, crag_routes.name, crag_routes.id')
                                  .page(page)
                       end
        render json: @crag_routes.map(&:summary_to_json), status: :ok
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
        # Ok if user have public profile && public outdoor ascents
        return if @user.public_profile && @user.public_outdoor_ascents

        # Ok if I have logged user && user have public outdoor logbook
        return if login? && @user.public_outdoor_ascents

        # Ok if current user is subscribe to user
        return if current_user_is_subscribed?

        render json: {}, status: :unauthorized
      end

      def protected_media
        # Ok if user have public profile
        return if @user.public_profile

        # Ok if current user is subscribe to user
        return if current_user_is_subscribed?

        render json: {}, status: :unauthorized
      end

      def current_user_is_subscribed?
        login? && User.current.subscribes.accepted.where(followable_type: 'User', followable_id: @user.id).exists?
      end

      def set_user
        @user = User.find_by uuid: params[:id]
      end
    end
  end
end
