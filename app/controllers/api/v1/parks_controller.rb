# frozen_string_literal: true

module Api
  module V1
    class ParksController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_park, only: %i[show update destroy]
      before_action :set_crag, only: %i[index geo_json_around show create update destroy]

      def index
        @parks = @crag.parks
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
          next if park.id.to_s == params.fetch('exclude_id', nil)

          features << park.to_geo_json
        end

        # Crag approaches
        @crag.approaches.each do |approach|
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
        @park = Park.new(park_params)
        @park.crag = @crag
        @park.user = @current_user
        if @park.save
          render 'api/v1/parks/show'
        else
          render json: { error: @park.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @park.update(park_params)
          render 'api/v1/parks/show'
        else
          render json: { error: @park.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @park.destroy
          render json: {}, status: :ok
        else
          render json: { error: @park.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_park
        @park = Park.find params[:id]
      end

      def set_crag
        @crag = Crag.find params[:crag_id]
      end

      def park_params
        params.require(:park).permit(
          :description,
          :latitude,
          :longitude
        )
      end
    end
  end
end
