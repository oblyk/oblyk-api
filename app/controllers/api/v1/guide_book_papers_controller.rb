# frozen_string_literal: true

module Api
  module V1
    class GuideBookPapersController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_crag remove_crag add_cover remove_cover]
      before_action :set_guide_book_paper, only: %i[crags photos links versions geo_json show update destroy add_crag remove_crag add_cover remove_cover articles]

      def index
        crag_id = params.fetch :crag_id, nil
        guide_book_papers = if crag_id
                              GuideBookPaper.includes(:guide_book_paper_crags)
                                            .where(guide_book_paper_crags: { crag_id: params[:crag_id] })
                            else
                              GuideBookPaper.all
                            end
        render json: guide_book_papers.map(&:summary_to_json), status: :ok
      end

      def crags
        crags = @guide_book_paper.crags
        render json: crags.map(&:summary_to_json), status: :ok
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

        @guide_book_paper.crags.each do |crag|
          features << crag.to_geo_json
        end

        @guide_book_paper.place_of_sales.each do |place_of_sale|
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
        photos = Photo.where(
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
        links = @guide_book_paper.links
        render json: links.map(&:summary_to_json), status: :ok
      end

      def articles
        articles = @guide_book_paper.articles.published
        render json: articles.map(&:summary_to_json), status: :ok
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
          :weight
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
