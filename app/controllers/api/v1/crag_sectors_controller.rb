# frozen_string_literal: true

module Api
  module V1
    class CragSectorsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag_sector, only: %i[show photos videos versions update destroy route_figures]
      before_action :set_crag, only: %i[index geo_json_around show create update]

      def index
        @crag_sectors = @crag.crag_sectors
      end

      def geo_json_around
        features = []

        features << @crag.to_geo_json

        @crag.crag_sectors.each do |sector|
          next if sector.latitude.blank? || sector.id.to_s == params.fetch('exclude_id', nil)

          features << sector.to_geo_json
        end

        # Crag parks
        @crag.parks.each do |park|
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

      def versions
        @versions = @crag_sector.versions
        render 'api/v1/versions/index'
      end

      def photos
        @photos = @crag_sector.all_photos
        render 'api/v1/photos/index'
      end

      def videos
        @videos = @crag_sector.all_videos
        render 'api/v1/photos/index'
      end

      def create
        @crag_sector = CragSector.new(crag_sector_params)
        @crag_sector.crag = @crag
        @crag_sector.user = @current_user
        if @crag_sector.save
          render 'api/v1/crag_sectors/show'
        else
          render json: { error: @crag_sector.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag_sector.update(crag_sector_params)
          render 'api/v1/crag_sectors/show'
        else
          render json: { error: @crag_sector.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @crag_sector.delete
          render json: {}, status: :ok
        else
          render json: { error: @crag_sector.errors }, status: :unprocessable_entity
        end
      end

      def route_figures
        render json: @crag_sector.route_figures
      end

      private

      def set_crag_sector
        @crag_sector = CragSector.includes(:user).find params[:id]
      end

      def set_crag
        @crag = Crag.find params[:crag_id]
      end

      def crag_sector_params
        params.require(:crag_sector).permit(
          :name,
          :description,
          :rain,
          :sun,
          :latitude,
          :longitude,
          :north,
          :north_east,
          :east,
          :south_east,
          :south,
          :south_west,
          :west,
          :north_west,
          :photo_id
        )
      end
    end
  end
end
