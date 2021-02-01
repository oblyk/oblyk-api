# frozen_string_literal: true

module Api
  module V1
    class AreasController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_area, only: %i[show crags geo_json photos add_crag remove_crag update destroy]

      def index
        @areas = Area.all
      end

      def search
        query = params[:query]
        @areas = Area.search(query).records
        render 'api/v1/areas/index'
      end

      def crags
        @crags = @area.crags
        render 'api/v1/crags/index'
      end

      def geo_json
        features = []

        # Crags
        @area.crags.each do |crag|
          # Crag sectors
          crag.crag_sectors.each do |sector|
            next unless sector.latitude

            features << sector.to_geo_json
          end

          # Crag parks
          crag.parks.each do |park|
            features << park.to_geo_json
          end

          # Crag approaches
          crag.approaches.each do |approach|
            features << approach.to_geo_json
          end

          features << crag.to_geo_json
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

      def photos
        @photos = @area.all_photos
        render 'api/v1/photos/index'
      end

      def create
        @area = Area.new(area_params)
        @area.user = @current_user
        if @area.save
          render 'api/v1/areas/show'
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @area.update(area_params)
          render 'api/v1/areas/show'
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @area.delete
          render json: {}, status: :ok
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def add_crag
        area_crag = AreaCrag.new(
          area_id: @area.id,
          crag_id: crag_params[:crag_id]
        )

        if area_crag.save
          render 'api/v1/areas/show'
        else
          render json: { error: area_crag.errors }, status: :unprocessable_entity
        end
      end

      def remove_crag
        area_crag = @area.area_crags.find_by crag_id: crag_params[:crag_id]

        if area_crag.delete
          render 'api/v1/areas/show'
        else
          render json: { error: area_crag.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_area
        @area = Area.find params[:id]
      end

      def crag_params
        params.require(:area).permit(
          :crag_id
        )
      end

      def area_params
        params.require(:area).permit(
          :name
        )
      end
    end
  end
end
