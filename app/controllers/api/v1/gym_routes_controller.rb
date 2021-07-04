# frozen_string_literal: true

module Api
  module V1
    class GymRoutesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space, except: %i[add_picture add_thumbnail dismount mount dismount_collection mount_collection]
      before_action :set_gym_sector, except: %i[index show add_picture add_thumbnail dismount mount dismount_collection mount_collection]
      before_action :set_gym_route, only: %i[show update destroy add_picture add_thumbnail dismount mount]

      def index
        @group_by = params.fetch(:group_by, nil)
        order_by = params.fetch(:order_by, nil)
        dismounted = params.fetch(:dismounted, false)

        if @group_by == 'sector'
          @sectors = if @gym_sector.present?
                       @gym_sector
                     elsif @gym_space.present?
                       GymSector.where(gym_space: @gym_space)
                     else
                       GymSector.joins(:gym_space).where(gym_spaces: { gym_id: @gym.id })
                     end
          @gym_routes = group_by_sector(@sectors, dismounted)
        else
          routes = if @gym_sector.present?
                     GymRoute.where(gym_sector: @gym_sector)
                   elsif @gym_space.present?
                     GymRoute.joins(:gym_sector).where(gym_sectors: { gym_space: @gym_space })
                   else
                     GymRoute.where(gym: @gym)
                   end

          # Mount or dismount
          @gym_routes = dismounted ? routes.dismounted : routes.mounted

          # Order
          @gym_routes = @gym_routes.order(opened_at: :desc) if order_by == 'opened_at'
          @gym_routes = @gym_routes.includes(gym_grade_line: :gym_grade).order('gym_grades.name ASC, gym_grade_lines.order DESC') if order_by == 'grade'
          @gym_routes = @gym_routes.includes(:sector).order('sectors.name ASC') if order_by == 'sector'

          # group by
          @gym_routes = group_by_opened_at(@gym_routes) if @group_by == 'opened_at'
          @gym_routes = group_by_grade(@gym_routes) if @group_by == 'grade'
        end
      end

      def show; end

      def create
        @gym_route = GymRoute.new(gym_route_params)
        @gym_route.gym_sector = @gym_sector
        if @gym_route.save
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_route.update(gym_route_params)
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_picture
        if @gym_route.update(picture_params)
          render 'api/v1/gym_routes/show'
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_thumbnail
        if @gym_route.update(thumbnail_params)
          render 'api/v1/gym_routes/show'
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
          grade = "#{route.gym_grade.id}-#{route.gym_grade_line.order}"
          grades[grade] = grades[grade] || { grade: grade, routes: [] }
          grades[grade][:routes] << route
        end
        grades
      end

      def set_gym_space
        @gym_space = GymSpace.find params[:gym_space_id]
      end

      def set_gym_sector
        @gym_sector = GymSector.find params[:gym_sector_id]
      end

      def set_gym_route
        @gym_route = GymRoute.find params[:id]
      end

      def gym_route_params
        params.require(:gym_route).permit(
          :name,
          :height,
          :climbing_type,
          :openers,
          :polyline,
          :gym_grade_line_id,
          :points,
          :opened_at,
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
