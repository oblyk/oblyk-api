# frozen_string_literal: true

module Api
  module V1
    class GymsController < ApiController
      include GymRolesVerification
      include UploadVerification

      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_banner add_logo routes_count routes tree_structures tree_routes figures comments videos stripe_customer_portal]
      before_action :set_gym, only: %i[show versions ascent_scores update destroy add_banner add_logo routes_count routes tree_structures tree_routes figures comments videos three_d stripe_customer_portal]
      before_action :protected_by_administrator, only: %i[update add_banner add_logo routes_count routes tree_structures tree_routes figures comments videos]
      before_action :user_can_manage_gym, except: %i[index search geo_json show create gyms_around versions ascent_scores routes_count routes comments videos three_d figures]
      before_action :user_can_manage_subscription, only: %i[stripe_customer_portal]

      def index
        gyms = params[:ids].present? ? Gym.where(id: params[:ids]) : Gym.all
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def search
        query = params[:query]
        gyms = Gym.search(query)
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def geo_json
        minimalistic = params.fetch(:minimalistic, false) != false
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: geo_json_features(minimalistic)
        }, status: :ok
      end

      def show
        render json: @gym.detail_to_json, status: :ok
      end

      def gyms_around
        distance = params.fetch(:distance, 20)
        gyms = Gym.geo_search(params[:latitude], params[:longitude], distance)
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def versions
        versions = @gym.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def ascent_scores
        start_date = params.fetch(:start_date, nil)
        end_date = params.fetch(:end_date, nil)
        start_date = Date.parse(start_date) if start_date
        end_date = Date.parse(end_date) if end_date
        gender = params.fetch(:gender, nil)
        age = params.fetch(:age, nil)
        climbing_type = params.fetch(:climbing_type, nil)

        ascents = AscentGymRoute.includes(:user, :gym_route, gym_route: :gym, user: { avatar_attachment: :blob })
                                .joins(gym_route: { gym_sector: :gym_space })
                                .where(gym: @gym)
                                .where.not(ascent_status: %w[project repetition])
                                .where.not(gym_route_id: nil)

        # Date filter
        ascents = if start_date || end_date
                    ascents.where(released_at: [start_date..end_date])
                           .where('gym_routes.opened_at <= :end_date AND (gym_routes.dismounted_at IS NULL OR gym_routes.dismounted_at >= :start_date)', end_date: end_date, start_date: start_date)
                           .where('ascents.created_at >= ?', start_date.beginning_of_day)
                           .where('ascents.created_at <= ?', (end_date + 1.day).end_of_day)
                  else
                    ascents.where(gym_routes: { dismounted_at: nil })
                  end

        # Gender filter
        ascents = ascents.where(users: { genre: gender }) if gender != 'all' && gender.present?

        # Climbing type filter
        ascents = ascents.joins(:gym_route).where(gym_routes: { climbing_type: climbing_type }) if climbing_type != 'all' && climbing_type.present?

        # Age filter
        if age.present?
          date_of_birth = nil
          date_of_birth = "users.date_of_birth > '#{Date.current - 6.years}'" if age == 'U6'
          date_of_birth = "users.date_of_birth > '#{Date.current - 8.years}'" if age == 'U8'
          date_of_birth = "users.date_of_birth > '#{Date.current - 10.years}'" if age == 'U10'
          date_of_birth = "users.date_of_birth > '#{Date.current - 12.years}'" if age == 'U12'
          date_of_birth = "users.date_of_birth > '#{Date.current - 14.years}'" if age == 'U14'
          date_of_birth = "users.date_of_birth > '#{Date.current - 16.years}'" if age == 'U16'
          date_of_birth = "users.date_of_birth > '#{Date.current - 18.years}'" if age == 'U18'
          date_of_birth = "users.date_of_birth > '#{Date.current - 20.years}'" if age == 'U20'
          date_of_birth = "users.date_of_birth BETWEEN '#{Date.current - 39.years}' AND '#{Date.current - 20.years}'" if age == 'senior'
          date_of_birth = "users.date_of_birth <= '#{Date.current - 40.years}'" if age == 'A40'
          date_of_birth = "users.date_of_birth <= '#{Date.current - 50.years}'" if age == 'A50'
          date_of_birth = "users.date_of_birth <= '#{Date.current - 60.years}'" if age == 'A60'
          ascents = ascents.joins(:user).where(date_of_birth) if date_of_birth
        end

        # Get limite of grade
        gym_routes = GymRoute.joins(gym_sector: :gym_space).where(gym_spaces: { gym_id: @gym.id })
        gym_routes = start_date.present? ? gym_routes.where('opened_at <= :start_date AND dismounted_at IS NULL OR dismounted_at >= :end_date', start_date: start_date, end_date: end_date) : gym_routes.mounted
        min_max = gym_routes.select('MIN(gym_routes.min_grade_value) AS min_grade_value, MAX(gym_routes.min_grade_value) AS max_grade_value, gym_routes.climbing_type').group(:climbing_type)&.group_by(&:climbing_type)

        # Get colors for charts
        chart_templates = {}
        @gym.gym_levels
            .where(enabled: true)
            .order("FIELD(climbing_type, 'sport_climbing', 'bouldering', 'pan')")
            .each do |gym_level|
          climbing_type = gym_level.climbing_type
          chart_templates[climbing_type] = {
            climbing_type: climbing_type,
            data: nil,
            colors: nil,
            grade_system: nil,
            min: nil,
            have_levels: false
          }
          chart_templates[climbing_type][:grade_system] = gym_level.grade_system
          chart_templates[climbing_type][:have_levels] = gym_level.levels.present?

          if gym_level.grade_system == 'french'
            min = min_max[gym_level.climbing_type].try(:first).try(:min_grade_value) || 0
            max = min_max[gym_level.climbing_type].try(:first).try(:max_grade_value) || 53
            chart_templates[climbing_type][:min] = min
            range = ((min / 2).to_i)..((max / 2).to_i)
            chart_templates[climbing_type][:colors] = Grade.degree_colors[range]
            chart_templates[climbing_type][:data] = range.map { |_index| 0 }
          elsif gym_level.levels
            chart_templates[climbing_type][:colors] = gym_level.levels.map { |level| level['color'] }
            chart_templates[climbing_type][:data] = gym_level.levels.map { |_index| 0 }
          elsif %w[usa_lead usa_bouldering pick_district].include? gym_level.grade_system
            chart_templates[climbing_type][:colors] = Grade.range_values(gym_level.grade_system.to_sym).map { |value| Grade::GRADES_COLOR[value] }
            chart_templates[climbing_type][:data] = Grade.range_values(gym_level.grade_system.to_sym).map { |_index| 0 }
          end
        end

        scores = {}
        ascents.find_each do |ascent|
          user_key = "user-#{ascent.user_id}"
          scores[user_key] ||= {
            points: 0,
            rank: nil,
            charts: chart_templates.deep_dup,
            user: ascent.user.summary_to_json
          }
          scores[user_key][:points] += ascent.points(ascent.gym_route, @gym)[:score] || 0
          climbing_type = ascent.gym_route.climbing_type

          grade_value = if chart_templates[climbing_type][:grade_system] == 'french'
                          (((ascent.gym_route.min_grade_value || 0) - (chart_templates[climbing_type][:min] || 0)) / 2).to_i
                        elsif chart_templates[climbing_type][:have_levels]
                          ascent.gym_route.level_index
                        else
                          Grade.range_values(chart_templates[climbing_type][:grade_system].to_sym).find_index(ascent.gym_route.min_grade_value - 1)
                        end
          scores[user_key][:charts][climbing_type][:data][grade_value] += 1 if grade_value.present?
        end

        scores = scores.map(&:last)
        scores.sort_by! { |score| -score[:points] }
        ranked_score = []
        scores.each_with_index do |score, index|
          score[:rank] = index + 1
          ranked_score << score
        end

        render json: ranked_score, status: :ok
      end

      def create
        @gym = Gym.new(gym_params)
        @gym.user = @current_user
        if @gym.save
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym.update(gym_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        return unless verify_file banner_params[:banner], :image

        if @gym.update(banner_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_logo
        return unless verify_file logo_params[:logo], :image

        if @gym.update(logo_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def routes_count
        render json: @gym.gym_routes.mounted.count, status: :ok
      end

      def routes
        space_id = params.fetch(:gym_space_id, nil)
        gym_routes = if space_id.present?
                       @gym.gym_routes.joins(:gym_sector).where(gym_sectors: { gym_space_id: space_id })
                     else
                       @gym.gym_routes.joins(gym_sector: :gym_space).where(gym_spaces: { archived_at: nil })
                     end
        gym_routes = if params.fetch(:dismounted, 'false') == 'true'
                       gym_routes.dismounted
                     else
                       gym_routes.mounted
                     end
        render json: gym_routes.map(&:summary_to_json), status: :ok
      end

      def tree_routes
        tree = []
        @gym.gym_spaces.unarchived.includes(:gym_sectors).each do |gym_space|
          space = {
            id: gym_space.id,
            name: gym_space.name,
            type: 'GymSpace',
            children: []
          }
          gym_space.gym_sectors.each do |gym_sector|
            sector = {
              id: gym_sector.id,
              name: gym_sector.name,
              type: 'GymSector',
              children: []
            }
            gym_sector.gym_routes.mounted.each do |gym_route|
              route = {
                id: gym_route.id,
                name: "#{gym_route.grade_to_s} #{gym_route.name}",
                route: gym_route.tree_summary.merge({ gym_space_name: gym_space.name, gym_sector_name: gym_sector.name }),
                type: 'GymRoute'
              }
              sector[:children] << route
            end
            space[:children] << sector
          end
          tree << space
        end
        render json: tree, status: :ok
      end

      def tree_structures
        tree = {
          gym: {
            name: @gym.name,
            slug_name: @gym.name,
            id: @gym.id,
            gym_spaces: [],
            gym_space_groups: [],
            archived_gym_spaces: []
          }
        }
        @gym.gym_space_groups.each do |gym_space_group|
          space_group = {
            id: gym_space_group.id,
            name: gym_space_group.name,
            order: gym_space_group.order,
            gym: {
              id: gym_space_group.gym_id,
              slug_name: gym_space_group.gym.id
            },
            gym_spaces: []
          }
          gym_space_group.gym_spaces.unarchived.each do |gym_space|
            sectors = []
            gym_space.gym_sectors.each do |gym_sector|
              sectors << gym_sector.summary_to_json
            end
            space = tree_structure_space_json gym_space, sectors
            space_group[:gym_spaces] << space
          end
          tree[:gym][:gym_space_groups] << space_group
        end
        @gym.gym_spaces.unarchived.where(gym_space_group_id: nil).each do |gym_space|
          sectors = []
          gym_space.gym_sectors.each do |gym_sector|
            sectors << gym_sector.summary_to_json
          end
          space = tree_structure_space_json gym_space, sectors
          tree[:gym][:gym_spaces] << space
        end

        # Archived spaces
        @gym.gym_spaces.archived.each do |gym_space|
          sectors = []
          gym_space.gym_sectors.each do |gym_sector|
            sectors << gym_sector.summary_to_json
          end
          space = tree_structure_space_json gym_space, sectors
          tree[:gym][:archived_gym_spaces] << space
        end

        render json: tree, status: :ok
      end

      def figures
        figures = params.fetch(:figures, [])
        data = {}
        data[:contests_count] = @gym.contests.unarchived.count if figures.include? 'contests_count'
        data[:championships_count] = @gym.all_championships.unarchived.count if figures.include? 'championships_count'
        data[:gym_spaces_count] = @gym.gym_spaces.count if figures.include? 'gym_spaces_count'
        data[:mounted_gym_routes_count] = @gym.gym_routes.mounted.count if figures.include? 'mounted_gym_routes_count'
        data[:gym_administrators_count] = @gym.gym_administrators.count if figures.include? 'gym_administrators_count'
        data[:gym_openers_count] = @gym.gym_openers.count if figures.include? 'gym_openers_count'
        if figures.include? 'comments_count'
          route_comments_count = Comment.joins('INNER JOIN gym_routes ON commentable_id = gym_routes.id')
                                        .joins('INNER JOIN gym_sectors ON gym_routes.gym_sector_id = gym_sectors.id')
                                        .joins('INNER JOIN gym_spaces ON gym_sectors.gym_space_id = gym_spaces.id')
                                        .where(
                                          gym_routes: { dismounted_at: nil },
                                          commentable_type: 'GymRoute',
                                          gym_spaces: { gym_id: @gym.id }
                                        )
                                        .count
          ascent_comments_count = Comment.joins('INNER JOIN ascents ON commentable_id = ascents.id')
                                         .joins('INNER JOIN gym_routes ON gym_route_id = gym_routes.id')
                                         .where(
                                           commentable_type: 'Ascent',
                                           gym_routes: { dismounted_at: nil },
                                           ascents: { gym_id: @gym.id }
                                         )
                                         .count
          data[:comments_count] = route_comments_count + ascent_comments_count
        end
        data[:videos_count] = Video.where(viewable_type: 'GymRoute', viewable_id: @gym.gym_routes.mounted.pluck(:id)).count if figures.include? 'videos_count'
        data[:followers_count] = Follow.where(followable_type: 'Gym', followable_id: @gym.id).count if figures.include? 'followers_count'
        render json: data, status: :ok
      end

      def comments
        page = params.fetch(:page, 1)
        route_comments_count = Comment.joins('INNER JOIN gym_routes ON commentable_id = gym_routes.id')
                                      .joins('INNER JOIN gym_sectors ON gym_routes.gym_sector_id = gym_sectors.id')
                                      .joins('INNER JOIN gym_spaces ON gym_sectors.gym_space_id = gym_spaces.id')
                                      .where(
                                        gym_routes: { dismounted_at: nil },
                                        commentable_type: 'GymRoute',
                                        gym_spaces: { gym_id: @gym.id }
                                      )
        ascent_comments_count = Comment.joins('INNER JOIN ascents ON commentable_id = ascents.id')
                                       .joins('INNER JOIN gym_routes ON gym_route_id = gym_routes.id')
                                       .where(
                                         commentable_type: 'Ascent',
                                         gym_routes: { dismounted_at: nil },
                                         ascents: { gym_id: @gym.id }
                                       )
        comments = Comment.from("(#{route_comments_count.to_sql} UNION #{ascent_comments_count.to_sql}) AS comments").order(updated_at: :desc).page(page)
        render json: comments.map(&:detail_to_json), status: :ok
      end

      def videos
        page = params.fetch(:page, 1)
        videos = Video.where(viewable_type: 'GymRoute', viewable_id: @gym.gym_routes.pluck(:id))
                      .order(created_at: :desc)
                      .page(page)
        render json: videos.map(&:detail_to_json), status: :ok
      end

      def three_d
        spaces = []
        assets = []

        # Space
        @gym.gym_spaces.unarchived.each do |space|
          next unless space.three_d?
          next if space.draft && !gym_team_user?

          spaces << {
            id: space.id,
            name: space.name,
            slug_name: space.slug_name,
            color: space.sectors_color,
            text_contrast_color: Color.black_or_white_rgb(space.sectors_color || 'rgb(49,153,78)'),
            three_d_gltf_url: space.three_d_gltf_url,
            three_d_parameters: space.three_d_parameters,
            three_d_position: space.three_d_position,
            three_d_rotation: space.three_d_rotation,
            three_d_scale: space.three_d_scale,
            three_d_label_options: space.three_d_label_options,
            draft: space.draft,
            gym: {
              id: space.gym.id,
              name: space.gym.name,
              slug_name: space.gym.slug_name
            }
          }
        end

        # Additional Assets
        @gym.gym_three_d_elements.each do |element|
          element_json = element.summary_to_json
          element_json[:gym_three_d_asset] = element.gym_three_d_asset.summary_to_json
          assets << element_json
        end
        render json: {
          spaces: spaces,
          assets: assets
        }, status: :ok
      end

      def stripe_customer_portal
        return if @gym.gym_billing_account.blank?

        stripe_portal = @gym.gym_billing_account.create_strip_portal!(@gym)

        return if stripe_portal.blank?

        render json: {
          url: stripe_portal.url
        }
      end

      private

      def geo_json_features(minimalistic)
        features = []
        gyms = minimalistic ? Gym.all : Gym.includes(banner_attachment: :blob).all
        gyms.each do |gym|
          features << gym.to_geo_json(minimalistic: minimalistic)
        end
        features
      end

      def tree_structure_space_json(gym_space, sectors)
        gym_space.summary_to_json.merge(
          {
            gym_sectors: sectors
          }
        )
      end

      def set_gym
        @gym = Gym.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def gym_params
        params.require(:gym).permit(
          :name,
          :description,
          :address,
          :postal_code,
          :code_country,
          :country,
          :city,
          :big_city,
          :region,
          :email,
          :phone_number,
          :web_site,
          :bouldering,
          :sport_climbing,
          :pan,
          :fun_climbing,
          :training_space,
          :boulder_ranking,
          :pan_ranking,
          :sport_climbing_ranking,
          :representation_type,
          :latitude,
          :longitude,
          ascents_multiplier: {
            sport_climbing: %i[onsight flash red_point lead_climb top_rope],
            bouldering: %i[onsight flash red_point],
            pan: %i[onsight flash red_point]
          }
        )
      end

      def banner_params
        params.require(:gym).permit(:banner)
      end

      def logo_params
        params.require(:gym).permit(:logo)
      end

      def user_can_manage_gym
        can? GymRole::MANAGE_GYM if @gym.administered?
      end

      def user_can_manage_subscription
        can? GymRole::MANAGE_SUBSCRIPTION if @gym.administered?
      end
    end
  end
end
