# frozen_string_literal: true

module Api
  module V1
    class GuideBookPapersController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_crag remove_crag add_cover remove_cover]
      before_action :set_guide_book_paper, only: %i[crags crags_figures photos links versions geo_json alternatives show update destroy add_crag remove_crag add_cover remove_cover articles]

      def index
        crag_id = params.fetch :crag_id, nil
        guide_book_papers = if crag_id
                              GuideBookPaper.includes(:guide_book_paper_crags, cover_attachment: :blob)
                                            .where(guide_book_paper_crags: { crag_id: params[:crag_id] })
                                            .order(publication_year: :desc)
                            else
                              GuideBookPaper.includes(cover_attachment: :blob).all.order(:name)
                            end
        render json: guide_book_papers.map(&:summary_to_json), status: :ok
      end

      def grouped
        group = params.fetch(:group, 'publication_year')
        direction = params.fetch(:direction, 'desc')
        groups = {}

        case group
        when 'publication_year'
          guides = GuideBookPaper.includes(cover_attachment: :blob).all.order(publication_year: direction)
          guides.each do |guide|
            groups["year-#{guide.publication_year}"] ||= { title: guide.publication_year, guides: [] }
            groups["year-#{guide.publication_year}"][:guides] << guide.summary_to_json
          end
          groups.sort_by do |k, _v|
            key = k || ''
            direction == 'desc' ? key : -key
          end.to_h
        when 'alphabetic'
          guides = GuideBookPaper.includes(cover_attachment: :blob).all.order(name: direction)
          guides.each do |guide|
            groups[guide.name.first] ||= { title: guide.name.first, guides: [] }
            groups[guide.name.first][:guides] << guide.summary_to_json
          end
        else
          {}
        end

        render json: groups, status: :ok
      end

      def crags
        crags = @guide_book_paper.crags.includes(photo: { picture_attachment: :blob })
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def crags_figures
        crag_statics = Statistics::CragStatistic.new
        crag_statics.crags = @guide_book_paper.crags

        crag_with_levels = {}
        @guide_book_paper.crags.select(
          :id,
          :name,
          :slug_name,
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
          :min_approach_time,
          :max_approach_time
        ).each do |crag|
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
        versions = @guide_book_paper.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def search
        query = params[:query]
        @guide_book_paper = GuideBookPaper.search(query)
        render json: @guide_book_paper.map(&:summary_to_json), status: :ok
      end

      def geo_json
        features = []

        @guide_book_paper.crags.includes(photo: { picture_attachment: :blob}).each do |crag|
          features << crag.to_geo_json
        end

        @guide_book_paper.place_of_sales.includes(:user).each do |place_of_sale|
          features << place_of_sale.to_geo_json
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

      def photos
        page = params.fetch(:page, 1)
        photos = Photo.includes(:illustrable, :user, picture_attachment: :blob).where(
          '(illustrable_type = "Crag" AND illustrable_id IN (SELECT crag_id FROM guide_book_paper_crags WHERE guide_book_paper_id = :guide_book_paper_id)) OR
           (illustrable_type = "CragSector" AND illustrable_id IN (SELECT id FROM crag_sectors WHERE crag_id IN (SELECT crag_id FROM guide_book_paper_crags WHERE guide_book_paper_id = :guide_book_paper_id))) OR
           (illustrable_type = "CragRoute" AND illustrable_id IN (SELECT id FROM crag_routes WHERE crag_id IN (SELECT crag_id FROM guide_book_paper_crags WHERE guide_book_paper_id = :guide_book_paper_id)))',
          guide_book_paper_id: @guide_book_paper.id
        )
                      .order(posted_at: :desc)
                      .page(page)
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def links
        links = @guide_book_paper.links.includes(:user)
        render json: links.map(&:summary_to_json), status: :ok
      end

      def articles
        articles = @guide_book_paper.articles.published
        render json: articles.map(&:summary_to_json), status: :ok
      end

      def alternatives
        alternatives = []
        @guide_book_paper.crags.includes(photo: :picture_attachment).each do |crag|
          crag_guide = {
            crag: crag.summary_to_json,
            guides: []
          }
          crag.guide_book_papers.includes(cover_attachment: :blob).order(publication_year: :desc).each do |guide|
            next if guide.id == @guide_book_paper.id

            crag_guide[:guides] << guide.summary_to_json
          end
          alternatives << crag_guide
        end

        render json: alternatives, status: :ok
      end

      def show
        render json: @guide_book_paper.detail_to_json, status: :ok
      end

      def create
        @guide_book_paper = GuideBookPaper.new(guide_book_params)
        @guide_book_paper.user = @current_user
        if @guide_book_paper.save
          render json: @guide_book_paper.detail_to_json, status: :ok
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @guide_book_paper.update(guide_book_params)
          render json: @guide_book_paper.detail_to_json, status: :ok
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @guide_book_paper.destroy
          render json: {}, status: :ok
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def add_crag
        guide_book_paper_crag = GuideBookPaperCrag.new(
          guide_book_paper_id: @guide_book_paper.id,
          crag_id: crag_params[:crag_id]
        )

        if guide_book_paper_crag.save
          render json: @guide_book_paper.detail_to_json, status: :ok
        else
          render json: { error: guide_book_paper_crag.errors }, status: :unprocessable_entity
        end
      end

      def remove_crag
        guide_book_paper_crag = @guide_book_paper.guide_book_paper_crags.find_by crag_id: crag_params[:crag_id]

        if guide_book_paper_crag.delete
          render json: @guide_book_paper.detail_to_json, status: :ok
        else
          render json: { error: guide_book_paper_crag.errors }, status: :unprocessable_entity
        end
      end

      def add_cover
        if @guide_book_paper.update(cover_params)
          render json: @guide_book_paper.detail_to_json, status: :ok
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def remove_cover
        @guide_book_paper.cover.purge if @guide_book_paper.cover.attached?
        render json: @guide_book_paper.detail_to_json, status: :ok
      end

      def around
        lat = params[:lat]
        lng = params[:lng]
        dist = params.fetch(:dist, '20').to_i
        dist = 100 if dist > 100
        guide_ids = []
        crags_around = Crag.includes(:guide_book_papers).geo_search(lat, lng, dist)
        crags_around.each do |crag|
          guide_ids.concat(crag.guide_book_papers.pluck(:id))
        end
        guide_book_papers = GuideBookPaper.includes(:crags).where(id: guide_ids)

        crags_around_ids = crags_around.pluck(:id)
        guides = []
        guide_book_papers.each do |guide|
          crags_in_area = []
          crags_out_of_area = []
          guide.crags.each do |crag|
            if crags_around_ids.include?(crag.id)
              crags_in_area << crag.summary_to_json
            else
              crags_out_of_area << crag.summary_to_json
            end
          end
          guides << {
            guide: guide.summary_to_json,
            geo_json: guide.crags_to_geo_json,
            crags_in_area: crags_in_area,
            crags_out_of_area: crags_out_of_area
          }
        end

        render json: guides, status: :ok
      end

      private

      def set_guide_book_paper
        @guide_book_paper = GuideBookPaper.find params[:id]
      end

      def guide_book_params
        params.require(:guide_book_paper).permit(
          :name,
          :author,
          :editor,
          :publication_year,
          :price_cents,
          :ean,
          :number_of_page,
          :vc_reference,
          :weight,
          :funding_status
        )
      end

      def crag_params
        params.require(:guide_book_paper).permit(
          :crag_id
        )
      end

      def cover_params
        params.require(:guide_book_paper).permit(
          :cover
        )
      end
    end
  end
end
