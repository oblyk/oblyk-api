# frozen_string_literal: true

module Api
  module V1
    class PublicationViewsController < ApiController
      def unread_count
        unless login? || Publication::PUBLISHABLE_TYPES.exclude?(params[:publishable_type])
          render json: 0, status: :ok
          return
        end

        publications = Publication.where(publishable_type: params[:publishable_type], publishable_id: params[:publishable_id])
                                  .where.not(published_at: nil)
                                  .where('publications.published_at >= ?', Time.current - 3.months)
                                  .where('NOT EXISTS(SELECT * FROM publication_views WHERE publication_id = publications.id AND publication_views.user_id = :user_id)', user_id: @current_user.id)

        render json: publications.count, status: :ok
      end

      def my_unread_count
        unless login?
          render json: 0, status: :ok
          return
        end

        publications = Publication.where.not(published_at: nil)
                                  .where(
                                    '(EXISTS (SELECT *
                                              FROM follows
                                              WHERE user_id = :current_user_id
                                                AND accepted_at IS NOT NULL
                                                AND followable_id = publications.publishable_id
                                                AND followable_type = publications.publishable_type)
                                                OR (publications.publishable_type = "User" AND publications.publishable_id = :current_user_id)
                                                OR publications.publishable_type = "Article"
                                                )',
                                    current_user_id: @current_user.id
                                  )
                                  .where('publications.published_at >= ?', Time.current - 3.months)
                                  .where('NOT EXISTS(SELECT * FROM publication_views WHERE publication_id = publications.id AND publication_views.user_id = :user_id)', user_id: @current_user.id)
        render json: publications.count, status: :ok
      end
    end
  end
end
