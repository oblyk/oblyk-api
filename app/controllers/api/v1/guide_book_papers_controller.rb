# frozen_string_literal: true

module Api
  module V1
    class GuideBookPapersController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_crag remove_crag add_cover remove_cover]
      before_action :set_guide_book_paper, only: %i[crags photos links versions geo_json show update destroy add_crag remove_crag add_cover remove_cover articles]

      def index
        crag_id = params.fetch :crag_id, nil
        @guide_book_papers = if crag_id
                               GuideBookPaper.includes(:guide_book_paper_crags)
                                             .where(guide_book_paper_crags: { crag_id: params[:crag_id] })
                             else
                               GuideBookPaper.all
                             end
      end

      def crags
        @crags = @guide_book_paper.crags
        render 'api/v1/crags/index'
      end

      def versions
        @versions = @guide_book_paper.versions
        render 'api/v1/versions/index'
      end

      def search
        query = params[:query]
        @guide_book_papers = GuideBookPaper.search(query).records
        render 'api/v1/guide_book_papers/index'
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
        @photos = @guide_book_paper.all_photos
        render 'api/v1/photos/index'
      end

      def links
        @links = @guide_book_paper.links
        render 'api/v1/links/index'
      end

      def articles
        @articles = @guide_book_paper.articles.published
        render 'api/v1/articles/index'
      end

      def show; end

      def create
        @guide_book_paper = GuideBookPaper.new(guide_book_params)
        @guide_book_paper.user = @current_user
        if @guide_book_paper.save
          render 'api/v1/guide_book_papers/show'
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @guide_book_paper.update(guide_book_params)
          render 'api/v1/guide_book_papers/show'
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @guide_book_paper.delete
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
          render 'api/v1/guide_book_papers/show'
        else
          render json: { error: guide_book_paper_crag.errors }, status: :unprocessable_entity
        end
      end

      def remove_crag
        guide_book_paper_crag = @guide_book_paper.guide_book_paper_crags.find_by crag_id: crag_params[:crag_id]

        if guide_book_paper_crag.delete
          render 'api/v1/guide_book_papers/show'
        else
          render json: { error: guide_book_paper_crag.errors }, status: :unprocessable_entity
        end
      end

      def add_cover
        if @guide_book_paper.update(cover_params)
          render 'api/v1/guide_book_papers/show'
        else
          render json: { error: @guide_book_paper.errors }, status: :unprocessable_entity
        end
      end

      def remove_cover
        @guide_book_paper.cover.purge if @guide_book_paper.cover.attached?
        render 'api/v1/guide_book_papers/show'
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
