# frozen_string_literal: true

module Api
  module V1
    class CragRoutesController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag_route, only: %i[show photos videos versions update destroy]
      before_action :set_crag_sector, only: %i[index search]
      before_action :set_crag, only: %i[index search]

      def index
        order_by = params.fetch(:order_by, 'difficulty_desc')
        order = case order_by
                when 'difficulty_desc'
                  'max_grade_value DESC'
                when 'difficulty_asc'
                  'max_grade_value ASC'
                when 'note'
                  'note DESC'
                else
                  'name'
                end

        crag_routes = if @crag
                        @crag.crag_routes.order(order)
                      elsif @crag_sector
                        @crag_sector.crag_routes.order(order)
                      else
                        CragRoute.where(crag_id: params[:crag_id]).order(order)
                      end
        @crag_routes = crag_routes.page(params.fetch(:page, 1))
      end

      def search
        query = params[:query]
        @crag_routes = if @crag_sector
                         CragRoute.search(query, nil, @crag_sector.id).records
                       elsif @crag
                         CragRoute.search(query, @crag.id, nil).records
                       else
                         CragRoute.search(query).records
                       end
        render 'api/v1/crag_routes/index'
      end

      def versions
        @versions = @crag_route.versions
        render 'api/v1/versions/index'
      end

      def photos
        page = params.fetch(:page, 1)
        @photos = @crag_route.photos
                             .order(posted_at: :desc)
                             .page(page)
        render 'api/v1/photos/index'
      end

      def videos
        @videos = @crag_route.videos
        render 'api/v1/videos/index'
      end

      def show; end

      def create
        @crag_route = CragRoute.new(crag_route_params)
        @crag_route.user = @current_user
        if @crag_route.save
          render 'api/v1/crag_routes/show'
        else
          render json: { error: @crag_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag_route.update(crag_route_params)
          render 'api/v1/crag_routes/show'
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

      def set_crag_sector
        @crag_sector = CragSector.find_by id: params[:crag_sector_id]
      end

      def set_crag
        @crag = Crag.find_by id: params[:crag_id]
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
