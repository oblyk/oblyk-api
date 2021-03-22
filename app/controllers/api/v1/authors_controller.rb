# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < ApiController
      before_action :protected_by_session, only: %i[update add_cover]
      before_action :set_author, only: %i[show update add_cover]
      before_action :protected_by_owner, only: %i[update add_cover]

      def show; end

      def update
        if @author.update(author_params)
          render 'api/v1/authors/show'
        else
          render json: { error: @author.errors }, status: :unprocessable_entity
        end
      end

      def add_cover
        if @author.update(cover_params)
          render 'api/v1/authors/show'
        else
          render json: { error: @author.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_author
        @author = Author.find params[:id]
      end

      def author_params
        params.require(:author).permit(
          :name,
          :description
        )
      end

      def cover_params
        params.require(:author).permit(
          :cover
        )
      end

      def protected_by_owner
        not_authorized if @current_user.id != @author.user_id
      end
    end
  end
end
