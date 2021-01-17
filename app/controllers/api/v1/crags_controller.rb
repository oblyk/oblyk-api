# frozen_string_literal: true

module Api
  module V1
    class CragsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag, only: %i[show update destroy guides photos videos]

      def index
        @crags = Crag.includes(:user, :crag_sectors).all
      end

      def search
        query = params[:query]
        @crags = Crag.search(query).records
        render 'api/v1/crags/index'
      end

      def geo_json
        features = []

        Crag.all.each do |crag|
          features << {
            type: 'Feature',
            properties: {
              id: crag.id,
              name: crag.name,
              slug_name: crag.slug_name,
              climbing_key: crag.climbing_key,
              icon: "crag-marker-#{crag.climbing_key}",
              localization: "#{crag.city}, #{crag.region}",
              sport_climbing: crag.sport_climbing,
              bouldering: crag.bouldering,
              multi_pitch: crag.multi_pitch,
              trad_climbing: crag.trad_climbing,
              aid_climbing: crag.aid_climbing,
              deep_water: crag.deep_water,
              via_ferrata: crag.via_ferrata,
              map_thumbnail_url: crag.photo.present? ? crag.photo.thumbnail_url : nil,
              route_count: crag.crag_routes_count,
              grade_min_value: crag.min_grade_value,
              grade_max_value: crag.max_grade_value,
              grade_max_text: crag.max_grade_text,
              grade_min_text: crag.min_grade_text
            },
            geometry: { type: 'Point', "coordinates": [Float(crag.longitude), Float(crag.latitude), 0.0] }
          }
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

      def guides
        papers = @crag.guide_book_papers
        pdfs = @crag.guide_book_pdfs
        webs = @crag.guide_book_webs
        guides = []

        papers.each do |paper|
          guides << {
            guide_type: 'GuideBookPaper',
            guide: JSON.parse(
              render_to_string(
                template: 'api/v1/guide_book_papers/search',
                assigns: { guide_book_paper: paper }
              )
            )
          }
        end

        pdfs.each do |pdf|
          guides << {
            guide_type: 'GuideBookPdf',
            guide: JSON.parse(
              render_to_string(
                template: 'api/v1/guide_book_pdfs/show',
                assigns: { guide_book_pdf: pdf }
              )
            )
          }
        end

        webs.each do |web|
          guides << {
            guide_type: 'GuideBookWeb',
            guide: JSON.parse(
              render_to_string(
                template: 'api/v1/guide_book_webs/show',
                assigns: { guide_book_web: web }
              )
            )
          }
        end
        render json: guides, status: :ok
      end

      def photos
        @photos = @crag.all_photos
        render 'api/v1/photos/index'
      end

      def videos
        @videos = @crag.all_videos
        render 'api/v1/videos/index'
      end

      def create
        @crag = Crag.new(crag_params)
        @crag.user = @current_user
        if @crag.save
          render 'api/v1/crags/show'
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag.update(crag_params)
          render 'api/v1/crags/show'
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @crag.delete
          render json: {}, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      private

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
