# frozen_string_literal: true

module Api
  module V1
    class CurrentUsersController < ApiController
      include UploadVerification

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

        latitude = params.fetch(:latitude, nil)
        longitude = params.fetch(:longitude, nil)

        articles_feed = Feed.where(feedable_type: 'Article')
        guide_books_feed = Feed.where(feedable_type: 'GuideBookPaper')
        local_feed = Feed.where(
          "getRange(latitude, longitude, :user_lat, :user_lng) < 30000 AND feedable_type IN ('Crag', 'CragRoute', 'GuideBookWeb', 'GuideBookPdf', 'Gym', 'Alert', 'Photo', 'Video')",
          user_lat: latitude.presence || User.current.latitude,
          user_lng: longitude.presence || User.current.longitude
        )

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
                          .includes(:user, followable: { photo: { picture_attachment: :blob } })
                          .where(followable_type: 'Crag')
                          .order(updated_at: :desc)
                          .page(params.fetch(:page, 1))
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def favorite_gyms
        subscribes = @user.subscribes
                          .includes(:user, followable: { photo: { picture_attachment: :blob } })
                          .where(followable_type: 'Gym')
                          .order(updated_at: :desc)
                          .page(params.fetch(:page, 1))
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def subscribes
        page = params.fetch(:page, 1)
        subscribes = @user.subscribes.includes(followable: { avatar_attachment: :blob }, user: { avatar_attachment: :blob }).where(followable_type: 'User').order(updated_at: :desc).page(page)
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def library
        subscribes = @user.subscribes.includes(:user, followable: { cover_attachment: :blob }).where(followable_type: 'GuideBookPaper').order(views: :desc)
        render json: subscribes.map(&:summary_to_json), status: :ok
      end

      def likes
        json_data = {}
        likes = @user.likes
                     .select(:likeable_type, :likeable_id)
                     .group_by { |like| like[:likeable_type] }
        likes.each { |k, v| json_data[k] = v.pluck(:likeable_id) }
        render json: json_data.to_json, status: :ok
      end

      def ascents_without_guides
        crag_ids = @user.ascended_crags.pluck(:id)
        library_guides = @user.subscribes.where(followable_type: 'GuideBookPaper').pluck(:followable_id)
        guides = GuideBookPaper
                 .includes(:guide_book_paper_crags, cover_attachment: :blob)
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
        followers = @user.follows.includes(user: { avatar_attachment: :blob }).accepted.order(created_at: :desc).page(page)
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

      def upcoming_contests
        contests = []
        contest_participations = @user.contest_participants
                                      .joins(contest_category: :contest)
                                      .where('contests.end_date >= ?', Date.current)
                                      .where('contests.subscription_start_date <= ?', Date.current)
        contest_participations.each do |contest_participation|
          contest = contest_participation.contest_category.contest.summary_to_json
          contest[:participant_token] = contest_participation.token
          contests << contest
        end
        render json: contests, status: :ok
      end

      def ascents_crag_routes
        render json: @user.ascent_crag_routes_to_a, status: :ok
      end

      def projects
        project_crag_route_ids = @user.ascent_crag_routes.project.pluck(:crag_route_id)
        crag_route_ids = @user.ascent_crag_routes.made.pluck(:crag_route_id)
        crag_routes = CragRoute.includes(crag: { photo: { picture_attachment: :blob } }, crag_sector: { photo: { picture_attachment: :blob } }, photo: { picture_attachment: :blob })
                               .where(id: project_crag_route_ids)
                               .where.not(id: crag_route_ids)
                               .joins(:crag)
                               .order('crags.name')
        render json: crag_routes.map { |crag_route| crag_route.summary_to_json(with_crag_in_sector: false) }, status: :ok
      end

      def tick_lists
        crag_routes = @user.ticked_crag_routes
                           .includes(
                             :crag_sector,
                             crag: {
                               photo: { picture_attachment: :blob },
                               static_map_banner_attachment: :blob,
                               static_map_attachment: :blob
                             },
                             photo: { picture_attachment: :blob }
                           )
                           .joins(:crag)
                           .order('crags.name')
        render json: crag_routes.map { |crag_route| crag_route.summary_to_json(with_crag_in_sector: false) }, status: :ok
      end

      def ascended_crags_geo_json
        minimalistic = params.fetch(:minimalistic, false) != false
        features = []

        crags = minimalistic ? @user.ascended_crags : @user.ascended_crags.includes(photo: { picture_attachment: :blob })
        crags.distinct.each do |crag|
          features << crag.to_geo_json(minimalistic: minimalistic)
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

      def subscribes_ascents
        page = params.fetch(:page, 1)
        subscribe_ids = @user.subscribes.accepted.where(followable_type: 'User').pluck(:followable_id)
        ascents = AscentCragRoute.made
                                 .where(user_id: subscribe_ids)
                                 .order(created_at: :desc, user_id: :asc)
                                 .page(page)

        ascent_crag_routes = []
        ascents.each do |ascent|
          ascent_route = ascent.summary_to_json(with_user: true)
          ascent_route[:crag_route][:grade_gap][:max_grade_value] = ascent.max_grade_value
          ascent_route[:crag_route][:grade_gap][:min_grade_value] = ascent.min_grade_value
          ascent_route[:crag_route][:grade_gap][:max_grade_text] = ascent.max_grade_text
          ascent_route[:crag_route][:grade_gap][:min_grade_text] = ascent.min_grade_text
          ascent_crag_routes << ascent_route
        end

        render json: ascent_crag_routes, status: :ok
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
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def update_password
        if @user.update(password_params)
          render json: @user.detail_to_json(current_user: true), status: :ok
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def banner
        return unless verify_file banner_params[:banner], :image

        if @user.update(banner_params)
          render json: @user.detail_to_json(current_user: true), status: :ok
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def avatar
        return unless verify_file avatar_params[:avatar], :image

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

      def partner_around_localities
        new_since = params.fetch(:new_since, nil) ? Date.parse(params[:new_since].to_s) : nil

        around_localities = []
        current_user_localities = @current_user.locality_users
                                               .activated
                                               .includes(:locality)
        current_user_localities.each do |current_user_locality|
          locality_users = LocalityUser
                           .activated
                           .joins(:user, :locality)
                           .where(users: { partner_search: true })
                           .where('users.last_activity_at > ?', Date.current - 3.years)
                           .where.not(user: @current_user)
                           .where(
                             'getRange(localities.latitude, localities.longitude, :lat, :lng) < :dist',
                             lat: current_user_locality.locality.latitude.to_f,
                             lng: current_user_locality.locality.longitude.to_f,
                             dist: current_user_locality.radius * 1000
                           )

          level = params.fetch(:level, nil)
          if level
            locality_users = locality_users.where(
              '(users.grade_min IS NULL OR users.grade_min <= :level) AND (users.grade_max IS NULL OR users.grade_max >= :level)',
              level: level
            )
          end

          climbing_type = params.fetch(:climbing_type, nil)
          locality_users = locality_users.where(users: { climbing_type => true }) if climbing_type

          around_localities.concat(locality_users.pluck(:id))
        end

        user_localities = LocalityUser.joins(:user)
                                      .includes(:user, :locality)
                                      .where(id: around_localities)
                                      .order('users.last_activity_at DESC, user_id')
                                      .page(params.fetch(:page, 1))

        json_user_localities = user_localities.map do |user_locality|
          data = user_locality.local_to_json
          data[:new] = new_since && data[:locality_user][:created_at] > new_since ? true : false
          data
        end

        render json: json_user_localities, status: :ok
      end

      def partner_figures
        locality_users = []
        user_ids = []
        new_partner = 0

        @current_user.locality_users.includes(:locality).each do |current_user_locality|
          LocalityUser
            .joins(:user, :locality)
            .where('users.last_activity_at > ?', Date.current - 3.years)
            .where(users: { partner_search: true })
            .where.not(user: @current_user)
            .where(
              'getRange(localities.latitude, localities.longitude, :lat, :lng) < :dist',
              lat: current_user_locality.locality.latitude.to_f,
              lng: current_user_locality.locality.longitude.to_f,
              dist: current_user_locality.radius * 1000
            ).each do |locality_user|
            locality_users << locality_user
            new_partner += 1 if @current_user.last_partner_check_at && locality_user.created_at > @current_user.last_partner_check_at
            user_ids << locality_user.user_id
          end
        end

        last_partners = User.where(id: user_ids)
                            .order(last_partner_check_at: :desc)
                            .limit(5)

        render json: {
          count: locality_users.count,
          new_partners: new_partner,
          last_partners: last_partners.map(&:local_climber_to_json)
        }, status: :ok
      end

      def partner_checked
        @current_user.partner_check!
        head :no_content
      end

      def gym_administrators
        render json: @current_user.gym_administrators.includes(:gym, :user).map(&:detail_to_json), status: :ok
      end

      def switch_email_report
        gym_administrator = @current_user.gym_administrators.find_by id: params[:gym_administrator][:id]
        gym_administrator.email_report = !gym_administrator.email_report
        gym_administrator.save
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

      def password_params
        params.require(:user).permit(
          :email,
          :password,
          :password_confirmation
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
