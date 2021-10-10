# frozen_string_literal: true

module Api
  module V1
    class ArticlesController < ApiController
      before_action :protected_by_super_admin, except: %i[index last feed show view crags guide_book_papers]
      before_action :set_article, except: %i[index last feed create]

      def index
        articles = Article.published
                          .order(published_at: :desc)
                          .page(params.fetch(:page, 1))
        render json: articles.map(&:summary_to_json), status: :ok
      end

      def last
        feeds = Feed.where(feedable_type: 'Article')
                    .order(posted_at: :desc)
                    .limit(3)
        render json: feeds, status: :ok
      end

      def feed
        feeds = Feed.where(feedable_type: 'Article')
                    .order(posted_at: :desc)
                    .page(params.fetch(:page, 1))
        render json: feeds, status: :ok
      end

      def show
        render json: @article.detail_to_json, status: :ok
      end

      def photos
        photos = @article.photos
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def crags
        crags = @article.crags
        render json: crags.map(&:summary_to_json), status: :ok
      end

      def guide_book_papers
        guide_book_papers = @article.guide_book_papers
        render json: guide_book_papers.map(&:summary_to_json), status: :ok
      end

      # POST /articles/:id/view
      def view
        @article.view! if @article.published?
        head :no_content
      end

      # PUT /articles/:id/publish
      def publish
        @article.publish!
        head :no_content
      end

      # PUT /articles/:id/un_publish
      def un_publish
        @article.unpublish!
        head :no_content
      end

      def create
        @article = Article.new(article_params)
        if @article.save
          render json: @article.detail_to_json, status: :ok
        else
          render json: { error: @article.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @article.update(article_params)
          render json: @article.detail_to_json, status: :ok
        else
          render json: { error: @article.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @article.destroy
          render json: {}, status: :ok
        else
          render json: { error: @article.errors }, status: :unprocessable_entity
        end
      end

      def add_cover
        if @article.update(cover_params)
          render json: @article.detail_to_json, status: :ok
        else
          render json: { error: @article.errors }, status: :unprocessable_entity
        end
      end

      def add_crag
        article_crag = ArticleCrag.new(
          article: @article,
          crag_id: crag_params[:crag_id]
        )
        article_crag.save
        head :no_content
      end

      def add_guide_book_paper
        article_guide_book_paper = ArticleGuideBookPaper.new(
          article: @article,
          guide_book_paper_id: guide_book_paper_params[:guide_book_paper_id]
        )
        article_guide_book_paper.save
        head :no_content
      end

      private

      def set_article
        @article = Article.find params[:id]
      end

      def article_params
        params.require(:article).permit(
          :name,
          :description,
          :body,
          :author_id
        )
      end

      def crag_params
        params.require(:article).permit(
          :crag_id
        )
      end

      def guide_book_paper_params
        params.require(:article).permit(
          :guide_book_paper_id
        )
      end

      def cover_params
        params.require(:article).permit(
          :cover
        )
      end
    end
  end
end
