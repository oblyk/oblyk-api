# frozen_string_literal: true

module Api
  module V1
    class GymRoutesController < ApiController
      include Gymable

      skip_before_action :protected_by_session, only: %i[show index ascents]
      skip_before_action :protected_by_gym_administrator, only: %i[show index ascents]
      before_action :set_gym_space, except: %i[add_picture similar_sectors add_thumbnail dismount mount dismount_collection mount_collection ascents]
      before_action :set_gym_sector, except: %i[index show similar_sectors add_picture add_thumbnail dismount mount dismount_collection mount_collection ascents]
      before_action :set_gym_route, only: %i[show similar_sectors update destroy add_picture add_thumbnail dismount mount ascents]
      before_action -> { can? GymRole::MANAGE_OPENING }, except: %i[index show similar_sectors ascents]

      def index
        group_by = params.fetch(:group_by, nil)
        order_by = params.fetch(:order_by, nil)
        dismounted = params.fetch(:dismounted, false)

        if group_by == 'sector'
          sectors = if @gym_sector.present?
                      @gym_sector
                    elsif @gym_space.present?
                      GymSector.where(gym_space: @gym_space)
                    else
                      GymSector.joins(:gym_space).where(gym_spaces: { gym_id: @gym.id })
                    end
          routes_json = { sectors: [] }
          sectors.each do |sector|
            routes = dismounted ? sector.gym_routes.dismounted : sector.gym_routes.mounted
            routes_json[:sectors] << {
              sector: sector.summary_to_json,
              routes: routes.map(&:summary_to_json)
            }
          end
          render json: routes_json, status: :ok
        else
          routes = if @gym_sector.present?
                     GymRoute.where(gym_sector: @gym_sector)
                   elsif @gym_space.present?
                     GymRoute.joins(:gym_sector).where(gym_sectors: { gym_space: @gym_space })
                   else
                     GymRoute.joins(:gym_space).where(gym_spaces: { gym: @gym })
                   end

          # Mount or dismount
          routes = dismounted ? routes.dismounted : routes.mounted

          # Order
          routes = routes.order(opened_at: :desc) if order_by == 'opened_at'
          routes = routes.order('max_grade_value DESC') if order_by == 'grade'
          routes = routes.includes(gym_grade_line: :gym_grade).order('gym_grade_lines.order DESC, gym_grades.name ASC') if order_by == 'level'
          routes = routes.includes(:sector).order('sectors.name ASC') if order_by == 'sector'

          # group by
          case group_by
          when 'opened_at'
            opened_routes = group_by_opened_at(routes)
            render json: { opened_at: opened_routes.map { |opened_route| { opened_at: opened_route[0], routes: opened_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'grade'
            grade_routes = group_by_grade(routes)
            render json: { grade: grade_routes.map { |grade_route| { grade: grade_route[0], routes: grade_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'level'
            level_routes = group_by_level(routes)
            render json: { level: level_routes.map { |level_route| { name: level_route[1][:name], colors: level_route[1][:colors], tag_color: level_route[1][:tag_color], hold_color: level_route[1][:hold_color], routes: level_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'point'
            render json: routes.sort_by { |route| -route.calculated_point }.map(&:summary_to_json), status: :ok
          else
            render json: routes.map(&:summary_to_json), status: :ok
          end
        end
      end

      def print
        gym_routes = GymRoute.where(id: params[:ids])
                             .order(:min_grade_value)

        pdf_html = ActionController::Base.new.render_to_string(
          template: 'api/v1/gym_routes/print.pdf.erb',
          locals: { gym_routes: gym_routes }
        )
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: "Fiche de voie - #{I18n.l(Date.current, format: :iso)} - #{@gym.name}.pdf"
      end

      def show
        render json: @gym_route.detail_to_json, status: :ok
      end

      def similar_sectors
        sectors = @gym_route.gym.gym_sectors.where(gym_space_id: @gym_route.gym_sector.gym_space_id, gym_grade_id: @gym_route.gym_sector.gym_grade_id)
        render json: sectors.map(&:summary_to_json), status: :ok
      end

      def ascents
        ascent_gym_routes = @gym_route.ascent_gym_routes
        render json: ascent_gym_routes.map(&:summary_to_json), status: :ok
      end

      def create
        @gym_route = GymRoute.new(gym_route_params)
        @gym_route.gym_sector = @gym_sector
        if @gym_route.save
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_route.update(gym_route_params)
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_picture
        if @gym_route.update(picture_params)
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_thumbnail
        if @gym_route.update(thumbnail_params)
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_route.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def dismount
        if @gym_route.dismount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def mount
        if @gym_route.mount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def dismount_collection
        @gym.gym_routes.where(id: params[:route_ids]).each(&:dismount!)
        head :no_content
      end

      def mount_collection
        @gym.gym_routes.where(id: params[:route_ids]).each(&:mount!)
        head :no_content
      end

      private

      def group_by_sector(sectors, dismount)
        groups = []
        sectors.each do |sector|
          routes = dismount ? sector.gym_routes.dismounted : sector.gym_routes.mounted
          groups << {
            sector: sector,
            routes: routes
          }
        end
        groups
      end

      def group_by_opened_at(routes)
        dates = {}
        routes.each do |route|
          date = route.opened_at.strftime '%Y-%m-%d'
          dates[date] = dates[date] || { opened_at: date, routes: [] }
          dates[date][:routes] << route
        end
        dates
      end

      def group_by_grade(routes)
        grades = {}
        routes.each do |route|
          next unless route.gym_grade.difficulty_by_grade?

          grade = route.max_grade_value
          grades[grade] = grades[grade] || { grade: grade, routes: [] }
          grades[grade][:routes] << route
        end
        grades
      end

      def group_by_level(routes)
        levels = {}
        routes.each do |route|
          next unless route.gym_grade.difficulty_by_level?
          next unless route.gym_grade_line

          level = "#{route.gym_grade.id}-#{route.gym_grade_line.order}"
          levels[level] = levels[level] || {
            name: route.gym_grade_line.name,
            colors: route.gym_grade_line.colors,
            tag_color: route.gym_grade.tag_color?,
            hold_color: route.gym_grade.hold_color?,
            routes: []
          }
          levels[level][:routes] << route
        end
        levels
      end

      def set_gym_space
        @gym_space = GymSpace.find_by id: params[:gym_space_id]
      end

      def set_gym_sector
        @gym_sector = GymSector.find_by id: params[:gym_sector_id]
      end

      def set_gym_route
        @gym_route = GymRoute.find params[:id]
      end

      def gym_route_params
        params.require(:gym_route).permit(
          :name,
          :height,
          :description,
          :climbing_type,
          :openers,
          :polyline,
          :gym_grade_line_id,
          :points,
          :opened_at,
          :gym_sector_id,
          gym_opener_ids: [],
          sections: [:climbing_type, :description, :grade, :height, { tags: [] }],
          hold_colors: %i[],
          tag_colors: %i[]
        )
      end

      def picture_params
        params.require(:gym_route).permit(
          :picture
        )
      end

      def thumbnail_params
        params.require(:gym_route).permit(
          :thumbnail
        )
      end
    end
  end
end
