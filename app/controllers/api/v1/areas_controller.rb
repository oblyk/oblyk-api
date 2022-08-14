# frozen_string_literal: true

module Api
  module V1
    class AreasController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_area, only: %i[show crags guide_book_papers geo_json photos add_crag remove_crag update destroy]

      def index
        render json: Area.includes(photo: { picture_attachment: :blob }).all.map(&:summary_to_json), status: :ok
      end

      def search
        query = params[:query]
        areas = Area.search(query)
        render json: areas.map(&:summary_to_json), status: :ok
      end

      def crags
        crags = @area.crags.includes(photo: { picture_attachment: :blob })
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def guide_book_papers
        crags = @area.crags
        guide_book_crags = GuideBookPaperCrag.where(crag_id: crags.pluck(:id))
        guide_books = GuideBookPaper.where(id: guide_book_crags.pluck(:guide_book_paper_id))
        render json: guide_books.map(&:summary_to_json), status: :ok
      end

      def geo_json
        features = []

        # Crags
        @area.crags.includes(:parks, :approaches, crag_sectors: { photo: { picture_attachment: :blob } }, photo: { picture_attachment: :blob }).each do |crag|
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

      def show
        render json: @area.detail_to_json, status: :ok
      end

      def photos
        page = params.fetch(:page, 1)
        photos = Photo.includes(:illustrable, :user, picture_attachment: :blob).where(
          '(illustrable_type = "Crag" AND illustrable_id IN (SELECT crag_id FROM area_crags WHERE area_id = :area)) OR
           (illustrable_type = "CragSector" AND illustrable_id IN (SELECT id FROM crag_sectors WHERE crag_id IN (SELECT crag_id FROM area_crags WHERE area_id = :area))) OR
           (illustrable_type = "CragRoute" AND illustrable_id IN (SELECT id FROM crag_routes WHERE crag_id IN (SELECT crag_id FROM area_crags WHERE area_id = :area)))',
          area: @area.id
        )
                      .order(posted_at: :desc)
                      .page(page)
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def create
        @area = Area.new(area_params)
        @area.user = @current_user
        if @area.save
          render json: @area.detail_to_json, status: :ok
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @area.update(area_params)
          render json: @area.detail_to_json, status: :ok
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @area.destroy
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
          render json: @area.detail_to_json, status: :ok
        else
          render json: { error: area_crag.errors }, status: :unprocessable_entity
        end
      end

      def remove_crag
        area_crag = @area.area_crags.find_by crag_id: crag_params[:crag_id]

        if area_crag.delete
          render json: @area.detail_to_json, status: :ok
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
          :name,
          :photo_id
        )
      end
    end
  end
end
