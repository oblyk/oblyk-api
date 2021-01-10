# frozen_string_literal: true

module Api
  module V1
    class CragRoutesController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag_route, only: %i[show update destroy]
      before_action :set_crag, only: %i[index]

      def index
        crag_routes = if @crag
                        @crag.crag_routes
                      else
                        CragRoute.where(crag_id: params[:crag_id])
                      end
        @crag_routes = crag_routes.page(params.fetch(:page, 1))
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
        if @crag_route.delete
          render json: {}, status: :ok
        else
          render json: { error: @crag_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_crag
        @crag = Crag.find params[:crag_id]
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
          sections: %i[climbing_type description grade height bolt_count bolt_type anchor_type incline_type]
        )
      end
    end
  end
end
