# frozen_string_literal: true

module Api
  module V1
    class WordsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_word, only: %i[show versions update destroy]

      def index
        words = Word.page(params.fetch(:page, 1))
        render json: words.map(&:summary_to_json), status: :ok
      end

      def search
        query = params.fetch(:query, nil)
        head :no_content && return if query.blank?

        page = params.fetch(:page, 1).to_i
        per_page = params.fetch(:per_page, 25).to_i

        hits = Word.search(
          query,
          page: page,
          hits_per_page: per_page
        )
        serializer = serializer(
          WordSerializer,
          hits,
          {
            meta: {
              query: query,
              current_page: hits.current_page,
              total_pages: hits.total_pages,
              total_count: hits.total_count,
              next_page: hits.next_page,
              prev_page: hits.prev_page
            }
          }
        )
        render json: serializer, status: :ok
      end

      def show
        render json: @word.detail_to_json, status: :ok
      end

      def versions
        versions = @word.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def create
        @word = Word.new(word_params)
        @word.user = @current_user
        if @word.save
          render json: @word.detail_to_json, status: :ok
        else
          render json: { error: @word.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @word.update(word_params)
          render json: @word.detail_to_json, status: :ok
        else
          render json: { error: @word.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @word.destroy
        head :no_content
      end

      private

      def set_word
        @word = Word.find params[:id]
      end

      def word_params
        params.require(:word).permit(
          :name,
          :definition
        )
      end
    end
  end
end
