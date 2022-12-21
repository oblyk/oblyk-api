# frozen_string_literal: true

module Api
  module V1
    class ClimbingSessionsController < ApiController
      before_action :protected_by_session
      before_action :set_climbing_session, only: %i[update show]

      # possible params
      # :gym_ids to filter to specific gym or gym array, example: gym_ids=1 or gym_ids[]=1&gym_ids[]=2
      # :crag_ids to filter to specific crag or crag array, example: crag_ids=1 or crag_ids[]=1&crag_ids[]=2
      # :only_crag to select climbing session with crag, example: only_crag=true
      # :only_gym to select climbing session with gym, example: only_gym=true
      def index
        gym_ids = params.fetch(:gym_ids, nil)
        crag_ids = params.fetch(:crag_ids, nil)
        only_crag = params.fetch(:only_crag, 'false') == 'true'
        only_gym = params.fetch(:only_gym, nil) == 'true'

        climbing_sessions = @current_user.climbing_sessions.includes(ascents: %i[color_system_line crag_route])

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
          sessions: climbing_sessions.map(&:summary_to_json),
          references: {
            crags: Crag.where(id: climbing_sessions.joins(:ascent_crag_routes).pluck(:crag_id)).map(&:summary_to_json),
            gyms: Gym.where(id: climbing_sessions.joins(:ascents).pluck(:gym_id)).map(&:summary_to_json)
          }
        }, status: :ok
      end

      def show
        render json: @climbing_session.detail_to_json, status: :ok
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
