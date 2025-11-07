# frozen_string_literal: true

module Api
  module V1
    class AscentGymRoutesController < ApiController
      before_action :protected_by_session
      before_action :set_ascent_gym_route, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        # Fetch filters
        gym_route_id = params.fetch(:gym_route_id, nil)
        gym_id = params.fetch(:gym_id, nil)
        ascent_status = params.fetch(:ascent_status, [])
        climbing_types = params.fetch(:climbing_types, [])

        # Ascents base
        ascent_gym_routes = @current_user.ascent_gym_routes

        # Ascents in gym
        ascent_gym_routes = ascent_gym_routes.where(gym_id: gym_id) if gym_id

        # Ascents in gym_route
        ascent_gym_routes = ascent_gym_routes.where(gym_route_id: gym_route_id) if gym_route_id

        # Filter by ascents status [project, sent, red_point, flash, onsight, repetition]
        ascent_gym_routes = ascent_gym_routes.where(ascent_status: ascent_status) if ascent_status.size.positive?

        # Filter by climbing types [sport_climbing, bouldering, pan]
        ascent_gym_routes = ascent_gym_routes.where(climbing_types: climbing_types) if climbing_types.size.positive?

        render json: ascent_gym_routes.map(&:summary_to_json), status: :ok
      end

      def gym_routes_infos_in_logbook
        route_ids = params.fetch(:route_ids, [])&.map(&:to_i)
        made_ids = AscentGymRoute.where(gym_route_id: route_ids, user: @current_user)
                                 .where.not(ascent_status: :project)
                                 .pluck(:gym_route_id)
                                 .uniq
        route_climbing_type = GymRoute.where(id: route_ids).group(:climbing_type).count
        new_ids = route_ids - made_ids

        render json: {
          made: made_ids,
          new: new_ids,
          climbing_types: route_climbing_type,
          gym_routes: GymRoute.where(id: route_ids).map(&:summary_to_json)
        }, status: :ok
      end

      def show
        render json: @ascent_gym_route.detail_to_json, status: :ok
      end

      def points
        user = User.find_by uuid: params[:user_uuid]
        gym = Gym.find_by id: params[:gym_id]
        page = params.fetch(:page, 1)
        start_date = params.fetch(:start_date, nil)
        end_date = params.fetch(:end_date, nil)
        climbing_type = params.fetch(:climbing_type, nil)

        gym_level = gym.gym_levels.find_by(climbing_type: climbing_type)

        ascents = user.ascent_gym_routes
                      .joins(gym_route: { gym_sector: :gym_space })
                      .where(gym_spaces: { gym_id: gym.id })
                      .where.not(ascent_status: %w[project repetition])

        ascents = if start_date.present?
                    ascents.where(released_at: start_date..end_date)
                  else
                    ascents.where(gym_routes: { dismounted_at: nil })
                  end

        ascents = ascents.where(gym_routes: { climbing_type: climbing_type }) if climbing_type.present?

        ascents = if gym_level.grade_system.blank?
                    ascents.order('gym_routes.level_index DESC, ascents.released_at DESC, ascents.id')
                  else
                    ascents.order('gym_routes.min_grade_value DESC, ascents.released_at DESC, ascents.id')
                  end

        ascents = ascents.page(page).map(&:summary_to_json)

        render json: ascents, status: :ok
      end

      def create
        @ascent_gym_route = AscentGymRoute.new(ascent_gym_route_params)
        @ascent_gym_route.user = @current_user

        if ascent_comment_params.fetch(:ascent_comment, []).fetch(:body, nil).present?
          @ascent_gym_route.ascent_comment = Comment.new ascent_comment_params[:ascent_comment]
          @ascent_gym_route.ascent_comment.user = @current_user
        end

        @ascent_gym_route.init_level_color if @ascent_gym_route.gym_route

        if @ascent_gym_route.save
          render json: gym_routes_ascent_response([@ascent_gym_route.gym_route_id]), status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      def create_bulk
        gym = Gym.find ascent_bulk_params[:gym_id]
        released_at = Date.parse(ascent_bulk_params[:released_at])

        new_ascents = []
        ascent_bulk_params[:ascents].each do |ascent|
          gym_ascent = AscentGymRoute.new(
            ascent_status: ascent[:ascent_status],
            quantity: ascent[:quantity],
            climbing_type: ascent_bulk_params[:climbing_type],
            height: ascent[:height],
            released_at: released_at,
            user: @current_user,
            gym: gym
          )
          grade = Grade.clean_grade ascent[:grade]
          grade_value = Grade.to_value grade
          gym_ascent.color_system_line_id = ascent[:color_system_line_id] if ascent_bulk_params[:ascents_by] == 'color'
          gym_ascent.sections = if ascent_bulk_params[:ascents_by] == 'grade'
                                  [{
                                    grade: grade,
                                    index: 0,
                                    height: ascent[:height],
                                    grade_value: grade_value
                                  }]
                                else
                                  [{
                                    grade: nil,
                                    index: 0,
                                    height: ascent[:height],
                                    grade_value: nil
                                  }]
                                end
          new_ascents << gym_ascent
        end

        errors = []
        new_ascents.each do |new_ascent|
          unless new_ascent.valid?
            errors << new_ascent.errors
            break
          end
        end

        if errors.size.zero?
          if ascent_bulk_params[:description].present?
            climbing_session = ClimbingSession.find_or_initialize_by(user: @current_user, session_date: released_at)
            ascent_description = climbing_session.description.present? ? "\n#{ascent_bulk_params[:description]}" : ascent_bulk_params[:description]
            climbing_session.description = ascent_description
            climbing_session.save
          end

          new_ascents.each(&:save)
          render json: { status: 'ok' }, status: :created
        else
          render json: { error: errors }, status: :unprocessable_entity
        end
      end

      def add_bulk
        new_ascents = []
        ascent_add_bulk_params[:gym_ascents].each do |ascent|
          gym_ascent = AscentGymRoute.new(
            ascent_status: ascent[:ascent_status],
            gym_route_id: ascent[:gym_route_id],
            hardness_status: ascent[:hardness_status],
            released_at: ascent[:released_at],
            roping_status: ascent[:roping_status],
            user: @current_user,
            selected_sections: [0]
          )
          if ascent[:ascent_comment].present? && ascent[:ascent_comment][:body].present?
            gym_ascent.ascent_comment = Comment.new(
              body: ascent[:ascent_comment][:body],
              user: @current_user,
              commentable_id: ascent[:gym_route_id],
              commentable_type: 'AscentGymRoute'
            )
          end
          new_ascents << gym_ascent
        end

        errors = []
        new_ascents.each do |new_ascent|
          unless new_ascent.valid?
            errors << new_ascent.errors
            break
          end
        end

        if errors.size.zero?
          new_ascents.each(&:save)
          render json: gym_routes_ascent_response(new_ascents.map(&:gym_route_id)), status: :created
        else
          render json: { error: errors.first }, status: :unprocessable_entity
        end
      end

      def update
        if ascent_comment_params.fetch(:ascent_comment, []).fetch(:body, nil).present?
          if @ascent_gym_route.ascent_comment
            @ascent_gym_route.ascent_comment.body = ascent_comment_params[:ascent_comment][:body]
          else
            @ascent_gym_route.ascent_comment = Comment.new(body: ascent_comment_params[:ascent_comment][:body])
            @ascent_gym_route.ascent_comment.user = @current_user
          end
        elsif @ascent_gym_route.ascent_comment
          @ascent_gym_route.ascent_comment = nil if @ascent_gym_route.ascent_comment.destroy
        end

        if @ascent_gym_route.update(ascent_gym_route_params)
          @ascent_gym_route.ascent_comment&.save
          render json: gym_routes_ascent_response([@ascent_gym_route.gym_route_id]), status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @ascent_gym_route.destroy
          render json: gym_routes_ascent_response([@ascent_gym_route.gym_route_id]), status: :created
        else
          render json: { error: @ascent_gym_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def gym_routes_ascent_response(gym_route_ids)
        route_ascents = {}
        gym_routes_ascents = AscentGymRoute.where(user: @current_user, gym_route_id: gym_route_ids)
                                           .order('ascent_status, "onsight", "flash", "red_point", "sent", "repetition", "project"')
        user_ascents = gym_routes_ascents.group_by(&:gym_route_id)

        gym_route_ids.each do |gym_route_id|
          ascents = user_ascents[gym_route_id]
          route_ascents[gym_route_id] = ascents&.map(&:logbook_summary_to_json) || []
        end
        route_ascents
      end

      def set_ascent_gym_route
        @ascent_gym_route = AscentGymRoute.find params[:id]
      end

      def ascent_gym_route_params
        params.require(:ascent_gym_route).permit(
          :ascent_status,
          :roping_status,
          :hardness_status,
          :gym_route_id,
          :gym_id,
          :level,
          :note,
          :comment,
          :released_at,
          :quantity,
          :color_system_line_id,
          :height,
          :climbing_type,
          sections: %i[grade index height grade_value],
          selected_sections: %i[]
        )
      end

      def ascent_comment_params
        params.require(:ascent_gym_route).permit(
          ascent_comment: %i[id body]
        )
      end

      def ascent_bulk_params
        params.require(:gym_ascents).permit(
          :ascents_by,
          :climbing_type,
          :gym_id,
          :description,
          :released_at,
          ascents: %i[height grade color_system_line_id quantity ascent_status]
        )
      end

      def ascent_add_bulk_params
        params.permit(
          gym_ascents: [
            :ascent_status,
            :gym_route_id,
            :hardness_status,
            :released_at,
            :roping_status,
            { ascent_comment: %i[body] }
          ]
        )
      end

      def ascent_user_params
        params.require(:ascent_user).permit(
          :user_id
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @ascent_gym_route.user_id
      end
    end
  end
end
