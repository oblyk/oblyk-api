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

      def geo_search
        crags = Crag.geo_search(
          params[:latitude],
          params[:longitude],
          params[:distance]
        )
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def advanced_search
        latitude = params.fetch(:latitude, nil)
        longitude = params.fetch(:longitude, nil)
        distance = params.fetch(:distance, 20).to_i * 1000
        distance = 50_000 if distance > 50_000
        max_approach_time = params.fetch(:max_approach_time, nil)
        orientation = params.fetch(:orientation, nil)
        climbing_type = params.fetch(:climbing_type, nil)
        season = params.fetch(:season, nil)
        grade = params.fetch(:grade, nil)

        crag_object = Crag.includes(:crag_routes, photo: { picture_attachment: :blob })

        # Approach time
        if max_approach_time.present?
          crag_object = crag_object.where(
            'max_approach_time <= :max_approach_time',
            max_approach_time: max_approach_time.to_i
          )
        end

        # Orientation
        if orientation.present?
          crag_object = crag_object.where('north OR north_east OR north_west') if orientation[:north]
          crag_object = crag_object.where('south OR south_east OR south_west') if orientation[:south]
          crag_object = crag_object.where('east OR south_east OR south_east') if orientation[:east]
          crag_object = crag_object.where('west OR north_west OR south_west') if orientation[:west]
        end

        # Climbing type
        if climbing_type.present?
          crag_object = crag_object.where('sport_climbing') if climbing_type[:sport_climbing]
          crag_object = crag_object.where('bouldering') if climbing_type[:bouldering]
          crag_object = crag_object.where('multi_pitch') if climbing_type[:multi_pitch]
          crag_object = crag_object.where('trad_climbing') if climbing_type[:trad_climbing]
          crag_object = crag_object.where('aid_climbing') if climbing_type[:aid_climbing]
          crag_object = crag_object.where('deep_water') if climbing_type[:deep_water]
          crag_object = crag_object.where('via_ferrata') if climbing_type[:via_ferrata]
        end

        # Season
        if season.present?
          crag_object = crag_object.where('summer') if season[:summer]
          crag_object = crag_object.where('autumn') if season[:autumn]
          crag_object = crag_object.where('winter') if season[:winter]
          crag_object = crag_object.where('spring') if season[:spring]
        end

        if grade.present?
          min_grade_value = Grade.to_value grade[:min]
          max_grade_value = Grade.to_value grade[:max]
          crag_object = crag_object.where('`crags`.`id` IN (SELECT DISTINCT c.id FROM crags c INNER JOIN crag_routes cr ON c.id = cr.crag_id WHERE cr.min_grade_value BETWEEN :min AND :max)', min: min_grade_value, max: max_grade_value)
        end

        # Localisation
        if latitude.present? && longitude.present?
          crag_object = crag_object.where(
            'getRange(latitude, longitude, :latitude, :longitude) <= :limit',
            latitude: latitude.to_f,
            longitude: longitude.to_f,
            limit: distance
          )
          crag_object = crag_object.order("getRange(latitude, longitude, #{latitude.to_f}, #{longitude.to_f})")
        else
          crag_object = crag_object.limit(params.fetch(:limit, 20))
        end

        crags = crag_object
        crag_statics = Statistics::CragStatistic.new
        crag_statics.crags = crags

        crag_with_levels = {}
        crags.each do |crag|
          crag_with_levels["crag-#{crag.id}"] ||= {
            levels: {},
            crag: crag
          }

          crag.crag_routes.each do |crag_route|
            next if crag_route.max_grade_value.zero?

            crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value] ||= { count: 0 }
            crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value][:count] += 1
          end
        end

        render json: {
          route_figures: crag_statics.route_figures,
          crag_with_levels: crag_with_levels
        }, status: :ok
      end

      def versions
        versions = @crag.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def random
        crag = Crag.order('RAND()').first
        render json: crag.detail_to_json, status: :ok
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
        minimalistic = params.fetch(:minimalistic, false) != false
        last_updated_crag = Crag.order(updated_at: :desc).first

        json_features = Rails.cache.fetch("#{last_updated_crag.cache_key_with_version}/#{'minimalistic_' if minimalistic}crags_geo_json", expires_in: 1.day) do
          geo_json_features(minimalistic)
        end

        json = {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: json_features
        }
        render json: json, status: :ok
      end

      def geo_json_around
        minimalistic = params.fetch(:minimalistic, false) != false
        features = []

        crags_around = if minimalistic
                         Crag.includes(photo: { picture_attachment: :blob }).geo_search(@crag.latitude, @crag.longitude, 50)
                       else
                         Crag.geo_search(@crag.latitude, @crag.longitude, 50)
                       end


        # Crags around this crag
        crags_around.each do |crag|
          features << crag.to_geo_json(minimalistic: minimalistic)
        end

        # Crag sectors
        crag_sectors = if minimalistic
                         @crag.crag_sectors
                       else
                         @crag.crag_sectors.includes(photo: { picture_attachment: :blob })
                       end
        crag_sectors.each do |sector|
          next unless sector.latitude

          features << sector.to_geo_json(minimalistic: minimalistic)
        end

        # Crag parks
        @crag.parks.each do |park|
          features << park.to_geo_json(minimalistic: minimalistic)
        end

        # Crag approaches
        @crag.approaches.each do |approach|
          features << approach.to_geo_json(minimalistic: minimalistic)
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
        papers = @crag.guide_book_papers.includes(cover_attachment: :blob)
        pdfs = @crag.guide_book_pdfs.includes(:user, pdf_file_attachment: :blob)
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
        photos = Photo.includes(:illustrable, :user, picture_attachment: :blob).where(
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

      def geo_json_features(minimalistic)
        features = []

        if minimalistic
          Crag.select(:id, :name, :sport_climbing, :multi_pitch, :trad_climbing, :aid_climbing, :bouldering, :deep_water, :via_ferrata, :longitude, :latitude, :updated_at).all.find_each do |crag|
            features << crag.to_geo_json(minimalistic: true)
          end
        else
          Crag.includes(photo: { picture_attachment: :blob }).all.each do |crag|
            features << crag.to_geo_json
          end
        end
        features
      end

      def set_crag
        @crag = Crag.find params[:id]
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
