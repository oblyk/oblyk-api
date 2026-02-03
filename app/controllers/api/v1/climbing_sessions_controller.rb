# frozen_string_literal: true

module Api
  module V1
    class ClimbingSessionsController < ApiController
      before_action :protected_by_session
      before_action :set_climbing_session, only: %i[show update show]

      # possible params
      # :gym_ids to filter to specific gym or gym array, example: gym_ids=1 or gym_ids[]=1&gym_ids[]=2
      # :crag_ids to filter to specific crag or crag array, example: crag_ids=1 or crag_ids[]=1&crag_ids[]=2
      # :only_crag to select climbing session with crag, example: only_crag=true
      # :only_gym to select climbing session with gym, example: only_gym=true
      # :user_id for see climbing session from other user, example: user_id=1
      def index
        gym_ids = params.fetch(:gym_ids, nil)
        crag_ids = params.fetch(:crag_ids, nil)
        only_crag = params.fetch(:only_crag, 'false') == 'true'
        only_gym = params.fetch(:only_gym, nil) == 'true'
        user_uuid = params.fetch(:user_uuid, nil)
        user = if user_uuid
                 other_user = User.where('EXISTS(SELECT followable_id
                                                 FROM follows
                                                 WHERE followable_type = "User"
                                                   AND followable_id = users.id
                                                   AND accepted_at IS NOT NULL
                                                   AND user_id = :current_user_id)',
                                         current_user_id: @current_user.id)
                                  .find_by(uuid: user_uuid)
                 other_user || @current_user
               else
                 @current_user
               end

        climbing_sessions = user.climbing_sessions.includes(ascents: %i[color_system_line crag_route])

        # Climbing session with gym_ids
        climbing_sessions = climbing_sessions.where('EXISTS(SELECT * FROM ascents WHERE gym_id IN(:gym_id) AND climbing_session_id = climbing_sessions.id)', gym_id: gym_ids) if gym_ids

        # Climbing session with crag_ids
        climbing_sessions = climbing_sessions.where('EXISTS(SELECT * FROM ascents INNER JOIN crag_routes ON crag_routes.id = ascents.crag_route_id WHERE crag_routes.crag_id IN(:crag_id) AND climbing_session_id = climbing_sessions.id)', crag_id: crag_ids) if crag_ids

        # Climbing session with only crags
        climbing_sessions = climbing_sessions.where('EXISTS(SELECT * FROM ascents WHERE crag_route_id IS NOT NULL AND climbing_session_id = climbing_sessions.id)') if only_crag

        # Climbing session with only gyms
        climbing_sessions = climbing_sessions.where('EXISTS(SELECT * FROM ascents WHERE gym_id IS NOT NULL AND climbing_session_id = climbing_sessions.id)') if only_gym

        # Pagination and ordering
        climbing_sessions = climbing_sessions.order(session_date: :desc).page(params.fetch(:page, 1))

        render json: {
          sessions: climbing_sessions.map { |climbing_session| climbing_session.summary_to_json(for_current_user: @current_user == user) },
          references: {
            crags: Crag.where(id: climbing_sessions.joins(:ascent_crag_routes).pluck(:crag_id)).map(&:summary_to_json),
            gyms: Gym.where(id: climbing_sessions.joins(:ascents).pluck(:gym_id)).map(&:summary_to_json)
          }
        }, status: :ok
      end

      def subscribes_climbing_sessions
        climbing_sessions = ClimbingSession.includes(ascents: %i[color_system_line crag_route])
                                           .where('EXISTS(SELECT *
                                                          FROM follows
                                                          WHERE follows.followable_id = climbing_sessions.user_id
                                                            AND follows.followable_type = "User"
                                                            AND follows.followable_id != :user_id
                                                            AND follows.accepted_at IS NOT NULL
                                                            AND follows.user_id = :user_id)',
                                                  user_id: @current_user.id)
                                           .order(session_date: :desc)
                                           .page(params.fetch(:page, 1))
        render json: {
          sessions: climbing_sessions.map(&:summary_to_json),
          references: {
            crags: Crag.where(id: climbing_sessions.joins(:ascent_crag_routes).pluck(:crag_id)).map(&:summary_to_json),
            gyms: Gym.where(id: climbing_sessions.joins(:ascents).pluck(:gym_id)).map(&:summary_to_json)
          }
        }, status: :ok
      end

      def friends_climbing_sessions
        # Sort users by last ascents
        users = User.select('users.*, (SELECT released_at FROM ascents WHERE ascents.user_id = users.id AND ascents.ascent_status != "project" ORDER BY released_at DESC LIMIT 1) AS last_released_at')
                    .where('EXISTS(SELECT *
                                   FROM follows
                                   WHERE follows.followable_type = "User"
                                     AND follows.followable_id = users.id
                                     AND follows.followable_id != :user_id
                                     AND follows.accepted_at IS NOT NULL
                                     AND follows.user_id = :user_id)',
                           user_id: @current_user.id)
                    .includes(avatar_attachment: :blob, banner_attachment: :blob)
                    .order('last_released_at DESC, users.id')
                    .page(params.fetch(:page, 1))
                    .per(10)

        # Get last hardest ascents by users
        user_ids = users.map(&:id)
        from_ascents = Ascent.select('*, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY released_at DESC,  min_grade_value DESC, gym_grade_level DESC) AS rn')
                             .where(user_id: user_ids)
                             .where.not(ascent_status: :project)
        max_ascent_by_users = Ascent.from("(#{from_ascents.to_sql}) AS ascents").where('rn = 1')

        max_ascent_by_users = max_ascent_by_users.map do |ascent|
          if ascent.max_grade_value.present?
            ascent_text = ascent.max_grade_text
            ascent_background_color = Grade::GRADES_COLOR[ascent.max_grade_value - 1]
          else
            ascent_text = nil
            ascent_background_color = ascent.gym_route.level_color
          end
          ascent_text_color = Color.black_or_white_rgb(ascent_background_color)
          released_at_is = if ascent.released_at.today?
                             'today'
                           elsif ascent.released_at == Date.current.yesterday
                             'yesterday'
                           elsif ascent.released_at > Date.current.beginning_of_week
                             'this_week'
                           end
          {
            user_id: ascent.user_id,
            released_at: ascent.released_at,
            released_at_is: released_at_is,
            today: ascent.released_at.today?,
            ascent_text: ascent_text,
            ascent_background_color: ascent_background_color,
            ascent_text_color: ascent_text_color
          }
        end

        max_ascent_by_users = max_ascent_by_users.group_by { |ascent| ascent[:user_id] }

        data = users.map do |user|
          {
            app_path: user.app_path,
            user_uuid: user.uuid,
            first_name: user.first_name,
            last_name: user.last_name,
            slug_name: user.slug_name,
            last_ascent: max_ascent_by_users[user.id]&.first,
            attachments: {
              avatar: user.attachment_object(user.avatar),
              banner: user.attachment_object(user.banner)
            }
          }
        end
        render json: data, status: :ok
      end

      def show
        user_id = params.fetch(:user_id, nil)

        if user_id.present?
          other_user = User.where('EXISTS(SELECT followable_id
                                          FROM follows
                                          WHERE followable_type = "User"
                                            AND followable_id = users.id
                                            AND accepted_at IS NOT NULL
                                            AND user_id = :current_user_id)',
                                  current_user_id: @current_user.id)
                           .find_by(id: user_id)
        end
        user = other_user || @current_user
        climbing_session = ClimbingSession.find_by(session_date: params[:id], user: user)

        if climbing_session
          render json: climbing_session.detail_to_json(for_current_user: user == @current_user), status: :ok
        else
          render json: nil, status: :not_found
        end
      end

      def update
        if @climbing_session.update(climbing_session_params)
          head :no_content
        else
          render json: { error: @climbing_session.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_climbing_session
        @climbing_session = ClimbingSession.find_by session_date: params[:id], user: @current_user
      end

      def climbing_session_params
        params.require(:climbing_session).permit(:description)
      end
    end
  end
end
