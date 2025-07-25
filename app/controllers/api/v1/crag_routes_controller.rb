# frozen_string_literal: true

module Api
  module V1
    class CragRoutesController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update suggested_routes]
      before_action :set_crag_route, only: %i[show photos videos versions update destroy]
      before_action :set_crag_sector, only: %i[index search search_by_grades]
      before_action :set_crag, only: %i[index search search_by_grades]
      before_action :set_area, only: %i[index search_by_grades]

      def index
        order_by = params.fetch(:order_by, 'difficulty_desc')
        order = case order_by
                when 'difficulty_desc'
                  'crag_routes.max_grade_value DESC, crag_routes.name, crag_routes.id'
                when 'difficulty_asc'
                  'crag_routes.max_grade_value ASC, crag_routes.name, crag_routes.id'
                when 'note'
                  'crag_routes.note DESC, crag_routes.name, crag_routes.id'
                when 'popularity'
                  'crag_routes.ascent_users_count DESC, crag_routes.ascents_count DESC, crag_routes.name, crag_routes.id'
                else
                  'crag_routes.name, crag_routes.id'
                end

        crag_routes = if @crag
                        @crag.crag_routes.includes(crag_sector: { photo: { picture_attachment: :blob } }, photo: { picture_attachment: :blob }).order(order)
                      elsif @crag_sector
                        @crag_sector.crag_routes.includes(:crag_sector).order(order)
                      elsif @area
                        @area.crag_routes.includes(:crag, :crag_sector, photo: { picture_attachment: :blob }).order(order)
                      else
                        CragRoute.includes(:crag_sector).where(crag_id: params[:crag_id]).order(order)
                      end

        crag_routes = crag_routes.page(params.fetch(:page, 1)).per(params.fetch(:page_limit, 25)) if params[:page] != 'all'

        render json: routes_summary(crag_routes), status: :ok
      end

      def suggested_routes
        ascents_count = AscentCragRoute.where(user_id: @current_user.id).count
        min_max = AscentCragRoute.select('MIN(min_grade_value) AS min_grade_value, MAX(max_grade_value) AS max_grade_value').find_by(user_id: @current_user.id) if ascents_count.positive?

        crag_routes = CragRoute.where('EXISTS (SELECT * FROM follows WHERE followable_type = "Crag" AND followable_id = crag_routes.crag_id AND follows.user_id = :user_id)', user_id: @current_user.id)
                               .where.not('EXISTS (SELECT * FROM ascents WHERE ascents.crag_route_id = crag_routes.id AND ascents.user_id = :user_id)', user_id: @current_user.id)
        crag_routes = crag_routes.where(max_grade_value: [min_max[:min_grade_value]..min_max[:max_grade_value] + 1]) if min_max
        crag_routes = crag_routes.order('ascent_users_count DESC, note_count DESC')
                                 .page(params.fetch(:page, 1))
                                 .per(params.fetch(:page_limit, 25))

        render json: crag_routes.map { |route| route.summary_to_json(with_crag_in_sector: false) }, status: :ok
      end

      def search
        query = params[:query]
        crag_routes = if @crag_sector
                        CragRoute.search_in_crag_sector(query, @crag_sector.id)
                      elsif @crag
                        CragRoute.search_in_crag(query, @crag.id)
                      else
                        CragRoute.search(query)
                      end
        render json: routes_summary(crag_routes), status: :ok
      end

      def search_by_grades
        grade_params = params[:grade]
        (1..9).each do |level|
          grade_params = "#{level}a #{level}c+" if grade_params == level.to_s
        end
        grades = grade_params.split ' '
        min_grade = Grade.to_value grades.first
        max_grade = grades[1] ? Grade.to_value(grades[1]) : min_grade
        sql_query = '(crag_routes.min_grade_value BETWEEN :min AND :max) OR (crag_routes.max_grade_value BETWEEN :min AND :max)'

        crag_routes = if @crag_sector
                        CragRoute.where(crag_sector: @crag_sector)
                                 .where(sql_query, min: min_grade, max: max_grade)
                                 .order(:min_grade_value)
                      elsif @crag
                        CragRoute.where(crag: @crag)
                                 .where(sql_query, min: min_grade, max: max_grade)
                                 .order(:min_grade_value)
                      elsif @area
                        @area.crag_routes
                             .where(sql_query, min: min_grade, max: max_grade)
                             .order(:min_grade_value)
                      else
                        CragRoute.where(sql_query, min: min_grade, max: max_grade)
                                 .order(:min_grade_value)
                      end

        render json: routes_summary(crag_routes), status: :ok
      end

      def versions
        versions = @crag_route.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def photos
        page = params.fetch(:page, 1)
        photos = @crag_route.photos
                            .order(posted_at: :desc)
                            .page(page)
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def videos
        videos = @crag_route.videos
        render json: videos.map(&:summary_to_json), status: :ok
      end

      def random
        crag_route = CragRoute.order('RAND()').first
        render json: crag_route.detail_to_json, status: :ok
      end

      def show
        render json: @crag_route.detail_to_json, status: :ok
      end

      def create
        @crag_route = CragRoute.new(crag_route_params)
        @crag_route.user = @current_user
        if @crag_route.save
          render json: @crag_route.detail_to_json, status: :ok
        else
          render json: { error: @crag_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag_route.update(crag_route_params)
          render json: @crag_route.detail_to_json, status: :ok
        else
          render json: { error: @crag_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @crag_route.destroy
          render json: {}, status: :ok
        else
          render json: { error: @crag_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def routes_summary(routes)
        user_is_login = login?
        routes.map do |crag_route|
          summary = crag_route.summary_to_json(with_crag_in_sector: false)
          summary[:name] = summary[:name].gsub(/\S/, '•') unless user_is_login
          summary
        end
      end

      def set_crag_sector
        @crag_sector = CragSector.find_by id: params[:crag_sector_id]
      end

      def set_crag
        @crag = Crag.find_by id: params[:crag_id]
      end

      def set_area
        @area = Area.find_by id: params[:area_id]
      end

      def set_crag_route
        @crag_route = CragRoute.find params[:id]
      end

      def crag_route_params
        params.require(:crag_route).permit(
          :name,
          :height,
          :open_year,
          :opener,
          :climbing_type,
          :incline_type,
          :reception_type,
          :start_type,
          :crag_id,
          :crag_sector_id,
          :photo_id,
          sections: [
            :climbing_type,
            :description,
            :grade,
            :height,
            :bolt_count,
            :bolt_type,
            :anchor_type,
            :incline_type,
            :start_type,
            :reception_type,
            { tags: [] }
          ]
        )
      end
    end
  end
end
