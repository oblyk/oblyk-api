# frozen_string_literal: true

module Api
  module V1
    class CurrentUsersController < ApiController
      before_action :protected_by_session
      before_action :set_user

      def show
        render json: @user.detail_to_json(current_user: true), status: :ok
      end

      def feed
        articles = params.fetch(:articles, false) == 'true'
        guide_books = params.fetch(:guide_books, false) == 'true'
        subscribes = params.fetch(:subscribes, false) == 'true'
        local_news = params.fetch(:local_news, false) == 'true'

        articles_feed = Feed.where(feedable_type: 'Article')
        guide_books_feed = Feed.where(feedable_type: 'GuideBookPaper')
        local_feed = Feed.where("getRange(latitude, longitude, :user_lat, :user_lng) < 30000 AND feedable_type IN ('Crag', 'CragRoute', 'GuideBookWeb', 'GuideBookPdf', 'Gym', 'Alert', 'Photo', 'Video')", user_lat: User.current.latitude, user_lng: User.current.longitude)

        crags = []
        gyms = []
        guides = []
        users = []
        if subscribes
          @current_user.subscribes.accepted.find_each do |subscribe|
            crags << subscribe.followable_id if subscribe.followable_type == 'Crag'
            gyms << subscribe.followable_id if subscribe.followable_type == 'Gym'
            guides << subscribe.followable_id if subscribe.followable_type == 'GuideBookPaper'
            users << subscribe.followable_id if subscribe.followable_type == 'User'
          end
        end
        subscribe_crags_feed = Feed.where(parent_type: 'Crag', parent_id: crags)
        subscribe_gyms_feed = Feed.where(parent_type: 'Gym', parent_id: gyms)
        subscribe_guides_feed = Feed.where(parent_type: 'GuideBookPaper', parent_id: guides)
        subscribe_users_feed = Feed.where(parent_type: 'User', parent_id: users)

        # Unselect all feeds by default for chained "or" after
        feeds = Feed.where('1 = 0')

        # Global feed
        feeds = feeds.or(articles_feed) if articles
        feeds = feeds.or(local_feed) if local_news
        feeds = feeds.or(guide_books_feed) if guide_books

        # Subscribe feed
        feeds = feeds.or(subscribe_crags_feed) if crags.count.positive?
        feeds = feeds.or(subscribe_gyms_feed) if gyms.count.positive?
        feeds = feeds.or(subscribe_guides_feed) if guides.count.positive?
        feeds = feeds.or(subscribe_users_feed) if users.count.positive?

        # Order & Pagination
        feeds = feeds.order(posted_at: :desc)
                     .page(params.fetch(:page, 1))
        render json: feeds, status: :ok
      end

      def favorite_crags
        subscribes = @user.subscribes
                          .where(followable_type: 'Crag')
                          .order(updated_at: :desc)
                          .page(params.fetch(:page, 1))
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def favorite_gyms
        subscribes = @user.subscribes
                          .where(followable_type: 'Gym')
                          .order(updated_at: :desc)
                          .page(params.fetch(:page, 1))
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def subscribes
        page = params.fetch(:page, 1)
        subscribes = @user.subscribes.where(followable_type: 'User').order(updated_at: :desc).page(page)
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def library
        subscribes = @user.subscribes.where(followable_type: 'GuideBookPaper').order(views: :desc)
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def ascents_without_guides
        crag_ids = @user.ascended_crags.pluck(:id)
        library_guides = @user.subscribes.where(followable_type: 'GuideBookPaper').pluck(:followable_id)
        guides = GuideBookPaper
                 .includes(:guide_book_paper_crags)
                 .where(guide_book_paper_crags: { crag_id: crag_ids })
                 .where(next_guide_book_paper_id: nil)
                 .where.not(id: library_guides)
                 .where("guide_book_papers.funding_status != 'not_contributes_to_financing' OR guide_book_papers.funding_status IS NULL")
                 .order(publication_year: :desc)
        render json: guides.map(&:summary_to_json), status: :ok
      end

      def new_guide_books_version
        subscribe_guides = @user.subscribes.where(followable_type: 'GuideBookPaper').pluck(:followable_id)
        old_guides = GuideBookPaper
                     .where(id: subscribe_guides)
                     .where.not(next_guide_book_paper_id: subscribe_guides)
        guides = []
        old_guides.each do |guide|
          guides << {
            old_guide: guide.summary_to_json,
            new_guide: guide.next_guide_book_paper.summary_to_json
          }
        end
        render json: guides, status: :ok
      end

      def library_figures
        subscribes = @user.subscribes.where(followable_type: 'GuideBookPaper')
        guide_books = GuideBookPaper.includes(:crags).where(id: subscribes.pluck(:followable_id))

        crags_count = 0
        routes_count = 0
        pages_count = 0
        sum_price = 0.0
        sum_weight = 0.0
        crags_id = []

        guide_books.each do |guide_book|
          pages_count += guide_book.number_of_page || 0
          sum_price += (guide_book.price_cents || 0).to_d
          sum_weight += (guide_book.weight || 0).to_d
          guide_book.crags.each do |crag|
            next if crags_id.include? crag.id

            crags_id << crag.id
            crags_count += 1
            routes_count += crag.crag_routes_count || 0
          end
        end

        sum_weight /= 1000 unless sum_weight.zero?
        sum_price /= 100 unless sum_price.zero?

        render json: {
          guide_book_count: guide_books.count,
          pages_count: pages_count,
          sum_price: sum_price,
          sum_weight: sum_weight,
          crags_count: crags_count,
          routes_count: routes_count
        }, status: :ok
      end

      def followers
        users = []
        page = params.fetch(:page, 1)
        followers = @user.follows.accepted.order(created_at: :desc).page(page)
        followers.each do |follower|
          users << follower.user
        end
        render json: users.map(&:summary_to_json), status: :ok
      end

      def waiting_followers
        users = []
        followers = @user.follows.awaiting_acceptance.order(created_at: :desc)
        followers.each do |follower|
          users << follower.user
        end
        render json: users.map(&:detail_to_json), status: :ok
      end

      def accept_followers
        follower = @user.follows.awaiting_acceptance.find_by user_id: params[:user_id]
        follower.accept!
      end

      def reject_followers
        follower = @user.follows.awaiting_acceptance.find_by user_id: params[:user_id]
        follower.reject!
      end

      def ascents_crag_routes
        render json: @user.ascent_crag_routes_to_a, status: :ok
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

        crag_routes = case params[:order]
                      when 'crags'
                        CragRoute.includes(:crag, :crag_sector)
                                 .where(id: crag_route_ids)
                                 .where(climbing_type: climbing_filters)
                                 .joins(:crag)
                                 .order('crags.name')
                                 .page(page)
                      when 'released_at'
                        CragRoute.joins("INNER JOIN ascents ON ascents.crag_route_id = crag_routes.id AND ascents.type = 'AscentCragRoute' AND ascents.user_id = #{@user.id}")
                                 .includes(:crag, :crag_sector)
                                 .where(id: crag_route_ids)
                                 .where(climbing_type: climbing_filters)
                                 .order('ascents.released_at DESC')
                                 .page(page)
                      else
                        CragRoute.includes(:crag, :crag_sector)
                                 .where(id: crag_route_ids)
                                 .where(climbing_type: climbing_filters)
                                 .order(max_grade_value: :desc)
                                 .page(page)
                      end
        render json: crag_routes.map(&:summary_to_json), status: :ok
      end

      def projects
        project_crag_route_ids = @user.ascent_crag_routes.project.pluck(:crag_route_id)
        crag_route_ids = @user.ascent_crag_routes.made.pluck(:crag_route_id)
        crag_routes = CragRoute.where(id: project_crag_route_ids).where.not(id: crag_route_ids).joins(:crag).order('crags.name')
        render json: crag_routes.map(&:summary_to_json), status: :ok
      end

      def tick_lists
        crag_routes = @user.ticked_crag_routes.joins(:crag).order('crags.name')
        render json: crag_routes.map(&:summary_to_json), status: :ok
      end

      def ascended_crags_geo_json
        features = []

        @user.ascended_crags.distinct.each do |crag|
          features << crag.to_geo_json
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

      def update
        if @user.update(user_params)
          render json: @user.detail_to_json(current_user: true), status: :ok
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def banner
        if @user.update(banner_params)
          render json: @user.detail_to_json(current_user: true), status: :ok
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def avatar
        if @user.update(avatar_params)
          render json: @user.detail_to_json(current_user: true), status: :ok
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def subscribe_to_newsletter
        render json: @user.subscribe_to_newsletter?, status: :ok
      end

      def destroy
        @user.delete
        head :no_content
      end

      private

      def set_user
        @user = @current_user
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :date_of_birth,
          :genre,
          :description,
          :latitude,
          :longitude,
          :localization,
          :partner_search,
          :bouldering,
          :sport_climbing,
          :multi_pitch,
          :trad_climbing,
          :aid_climbing,
          :deep_water,
          :via_ferrata,
          :pan,
          :grade_max,
          :grade_min,
          :language,
          :public_profile,
          :public_outdoor_ascents,
          :public_indoor_ascents,
          :partner_latitude,
          :partner_longitude,
          email_notifiable_list: %i[]
        )
      end

      def banner_params
        params.require(:user).permit(
          :banner
        )
      end

      def avatar_params
        params.require(:user).permit(
          :avatar
        )
      end
    end
  end
end
