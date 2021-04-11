# frozen_string_literal: true

module Api
  module V1
    class ApproachesController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag, only: %i[index geo_json_around show create]
      before_action :set_approach, only: %i[show update destroy]

      def index
        @approaches = @crag.approaches
      end

      def geo_json_around
        features = []

        features << @crag.to_geo_json

        @crag.crag_sectors.each do |sector|
          next unless sector.latitude

          features << sector.to_geo_json
        end

        # Crag parks
        @crag.parks.each do |park|
          features << park.to_geo_json
        end

        # Crag approaches
        @crag.approaches.each do |approach|
          next if approach.id.to_s == params.fetch('exclude_id', nil)

          features << approach.to_geo_json
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

      def show; end

      def create
        @approach = Approach.new(approach_params)
        @approach.polyline = params[:approach][:polyline]
        @approach.user = @current_user
        @approach.crag = @crag
        if @approach.save
          render 'api/v1/approaches/show'
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      def update
        @approach.polyline = params[:approach][:polyline]
        if @approach.update(approach_params)
          render 'api/v1/approaches/show'
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @approach.destroy
          render json: {}, status: :ok
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_crag
        @crag = Crag.find params[:crag_id]
      end

      def set_approach
        @approach = Approach.find params[:id]
      end

      def approach_params
        params.require(:approach).permit(
          :description,
          :length,
          :approach_type
        )
      end
    end
  end
end
