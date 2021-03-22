# frozen_string_literal: true

module Api
  module V1
    class ArticlesController < ApiController
      before_action :protected_by_super_admin, only: %i[create update destroy publish add_cover add_crag add_guide_book_paper]
      before_action :set_article, only: %i[show update destroy view publish add_cover add_crag add_guide_book_paper]

      def index
        @articles = Article.published
                           .order(published_at: :desc)
                           .page(params.fetch(:page, 1))
      end

      def show; end

      # POST /articles/:id/view
      def view
        @article.view!
      end

      # PUT /articles/:id/publish
      def publish
        @article.publish!
      end

      def create
        @article = Article.new(article_params)
        if @article.save
          render 'api/v1/articles/show'
        else
          render json: { error: @article.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @article.update(article_params)
          render 'api/v1/articles/show'
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
          render 'api/v1/articles/show'
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
      end

      def add_guide_book_paper
        article_guide_book_paper = ArticleGuideBookPaper.new(
          article: @article,
          guide_book_paper_id: guide_book_paper_params[:guide_book_paper_id]
        )
        article_guide_book_paper.save
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
