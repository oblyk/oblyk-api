# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :protected_by_session, only: %i[search]
      before_action :set_user, except: %i[search]
      before_action :protected_private_profile, except: %i[search]
      before_action :protected_media, only: %i[photos videos]
      before_action :protected_outdoor_log_book, only: %i[outdoor_figures outdoor_climb_types_chart ascended_crag_routes outdoor_grades_chart]
      before_action :protected_indoor_log_book, only: %i[indoor_figures indoor_climb_types_chart indoor_grade_chart indoor_by_level_chart]
      before_action :set_indoor_ascents, only: %i[indoor_grade_chart indoor_by_level_chart]
      before_action :set_filters, only: %i[ascended_crag_routes outdoor_grades_chart outdoor_figures outdoor_climb_types_chart]

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
        render json: LogBook::Outdoor::Figure.new(@filters).figures, status: :ok
      end

      def outdoor_climb_types_chart
        render json: LogBook::Outdoor::Chart.new(@filters).climb_type, status: :ok
      end

      def ascended_crag_routes
        page = params.fetch(:page, 1)

        # note that we don't apply the Rails filters here (eg no-double filter is not applied)
        ascents = @filters.filtered_ascents_active_record
                          .joins(crag_route: :crag)
                          .includes(
                            crag_route: {
                              crag_sector: { photo: { picture_attachment: :blob } },
                              crag: { photo: { picture_attachment: :blob } },
                              photo: { picture_attachment: :blob }
                            },
                            )

        ascents = case params[:order]
                  when 'crags' # TODO esty ce qu'on continue a filtrer specifiquement ici les repetitions
                    ascents.order('crags.name, crag_routes.name, crag_routes.id')
                  when 'released_at'
                    ascents.order('ascents.released_at DESC, crag_routes.name, crag_routes.id')
                  else
                    ascents.order('ascents.max_grade_value DESC, crag_routes.name, crag_routes.id')
                  end

        ascents = ascents.page(page)
        ascent_routes = []
        ascents.each do |ascent|
          route = ascent.crag_route.summary_to_json(with_crag_in_sector: false)
          route[:grade_gap][:max_grade_value] = ascent.max_grade_value
          route[:grade_gap][:min_grade_value] = ascent.min_grade_value
          route[:grade_gap][:max_grade_text] = ascent.max_grade_text
          route[:grade_gap][:min_grade_text] = ascent.min_grade_text
          route[:released_at] = ascent.released_at
          ascent_routes << route
        end

        render json: ascent_routes, status: :ok
      end

      def outdoor_grades_chart
        render json: LogBook::Outdoor::Chart.new(@filters).grade, status: :ok
      end

      def indoor_figures
        render json: LogBook::Indoor::Figure.new(@user).figures, status: :ok
      end

      def indoor_climb_types_chart
        render json: LogBook::Indoor::Chart.new(@user).climb_type, status: :ok
      end

      def indoor_grade_chart
        render json: LogBook::Indoor::Chart.grade(@ascents), status: :ok
      end

      def indoor_by_level_chart
        render json: LogBook::Indoor::Chart.by_levels(@ascents), status: :ok
      end

      def localities
        render json: @user.locality_users.activated.map(&:summary_to_json), status: :ok
      end

      private

      def protected_private_profile
        return if @user.public_profile
        return if login?

        render json: {}, status: :forbidden
      end

      def protected_outdoor_log_book
        # Ok if user have public profile && public outdoor ascents
        return if @user.public_profile && @user.public_outdoor_ascents

        # Ok if I have logged user && user have public outdoor logbook
        return if login? && @user.public_outdoor_ascents

        # Ok if current user is subscribe to user
        return if current_user_is_subscribed?

        render json: {}, status: :forbidden
      end

      def protected_indoor_log_book
        # Ok if user have public profile && public indoor ascents
        return if @user.public_profile && @user.public_indoor_ascents

        # Ok if I have logged user && user have public indoor logbook
        return if login? && @user.public_indoor_ascents

        # Ok if current user is subscribe to user
        return if current_user_is_subscribed?

        render json: {}, status: :forbidden
      end

      def protected_media
        # Ok if user have public profile
        return if @user.public_profile

        # Ok if current user is subscribe to user
        return if current_user_is_subscribed?

        render json: {}, status: :forbidden
      end

      def current_user_is_subscribed?
        login? && User.current.subscribes.accepted.where(followable_type: 'User', followable_id: @user.id).exists?
      end

      def set_user
        @user = if /^[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}$/.match? params[:id].to_s
                  User.find_by uuid: params[:id]
                else
                  User.find_by slug_name: params[:id]
                end
      end

      def set_filters
        @filters = CragAscentFilters.new(@user, params)
      end

      def set_indoor_ascents
        @ascents = @user.ascent_gym_routes.made.includes(color_system_line: :color_system)
      end
    end
  end
end
