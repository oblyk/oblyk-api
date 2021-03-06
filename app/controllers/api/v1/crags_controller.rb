# frozen_string_literal: true

module Api
  module V1
    class CragsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag, only: %i[show versions update guide_books_around areas_around geo_json_around destroy guides photos videos articles route_figures]

      def index
        render json: Crag.all.map(&:summary_to_json), status: :ok
      end

      def search
        query = params[:query]
        crags = Crag.search(query)
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def versions
        versions = @crag.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def random
        crag = Crag.order('RAND()').first
        render json: crag.detail_to_json, status: :ok
      end

      def geo_search
        crags = Crag.geo_search(
          params[:latitude],
          params[:longitude],
          params[:distance]
        )
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def guide_books_around
        guides_already_have = @crag.guide_book_papers.pluck(:id)
        guide_ids = []
        crags_around = Crag.geo_search(@crag.latitude, @crag.longitude, 50)
        crags_around.each do |crag|
          guide_ids.concat(crag.guide_book_papers.pluck(:id)) if crag.guide_book_papers.count.positive?
        end
        other_guides = guide_ids - guides_already_have
        guide_book_papers = GuideBookPaper.where(id: other_guides)
        render json: guide_book_papers.map(&:summary_to_json), status: :ok
      end

      def areas_around
        areas_already_have = @crag.areas.pluck(:id)
        area_ids = []
        crags_around = Crag.geo_search(@crag.latitude, @crag.longitude, 50)
        crags_around.each do |crag|
          area_ids.concat(crag.areas.pluck(:id)) if crag.areas.count.positive?
        end
        other_areas = area_ids - areas_already_have
        areas = Area.where(id: other_areas)
        render json: areas.map(&:summary_to_json), status: :ok
      end

      def geo_json
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: geo_json_features
        }, status: :ok
      end

      def geo_json_around
        features = []
        crags_around = Crag.geo_search(@crag.latitude, @crag.longitude, 50)

        # Crags around this crag
        crags_around.each do |crag|
          features << crag.to_geo_json
        end

        # Crag sectors
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

      def show
        render json: @crag.detail_to_json, status: :ok
      end

      def guides
        papers = @crag.guide_book_papers
        pdfs = @crag.guide_book_pdfs
        webs = @crag.guide_book_webs
        guides = []

        papers.each do |paper|
          guides << {
            guide_type: 'GuideBookPaper',
            guide: paper.summary_to_json
          }
        end

        pdfs.each do |pdf|
          guides << {
            guide_type: 'GuideBookPdf',
            guide: pdf.summary_to_json
          }
        end

        webs.each do |web|
          guides << {
            guide_type: 'GuideBookWeb',
            guide: web.summary_to_json
          }
        end
        render json: guides, status: :ok
      end

      def photos
        page = params.fetch(:page, 1)
        photos = Photo.where(
          '(illustrable_type = "Crag" AND illustrable_id = :crag_id) OR
           (illustrable_type = "CragSector" AND illustrable_id IN (SELECT id FROM crag_sectors WHERE crag_id = :crag_id)) OR
           (illustrable_type = "CragRoute" AND illustrable_id IN (SELECT id FROM crag_routes WHERE crag_id = :crag_id))',
          crag_id: @crag.id
        )
                      .order(posted_at: :desc)
                      .page(page)
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def videos
        videos = Crag.includes(:videos, crag_routes: :videos).find(params[:id]).all_videos
        render json: videos.map(&:summary_to_json), status: :ok
      end

      def articles
        articles = @crag.articles.published
        render json: articles.map(&:summary_to_json), status: :ok
      end

      def route_figures
        render json: @crag.route_figures, status: :ok
      end

      def crags_around
        distance = params.fetch(:distance, 20)
        crags = Crag.geo_search(params[:latitude], params[:longitude], distance)
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def create
        @crag = Crag.new(crag_params)
        @crag.user = @current_user
        if @crag.save
          render json: @crag.detail_to_json, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag.update(crag_params)
          render json: @crag.detail_to_json, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @crag.destroy
          render json: {}, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      private

      def geo_json_features
        features = []

        Crag.all.each do |crag|
          features << crag.to_geo_json
        end
        features
      end

      def set_crag
        @crag = Crag.includes(:user, :crag_sectors).find params[:id]
      end

      def crag_params
        params.require(:crag).permit(
          :name,
          :rain,
          :sun,
          :latitude,
          :longitude,
          :code_country,
          :country,
          :city,
          :region,
          :sport_climbing,
          :bouldering,
          :multi_pitch,
          :trad_climbing,
          :aid_climbing,
          :deep_water,
          :via_ferrata,
          :north,
          :north_east,
          :east,
          :south_east,
          :south,
          :south_west,
          :west,
          :north_west,
          :summer,
          :autumn,
          :winter,
          :spring,
          :photo_id,
          rocks: %i[]
        )
      end
    end
  end
end
