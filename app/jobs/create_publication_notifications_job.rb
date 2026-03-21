# frozen_string_literal: true

class CreatePublicationNotificationsJob < ApplicationJob
  queue_as :low

  def perform(publication_id)
    publication = Publication.find_by id: publication_id
    return unless publication
    return if publication.published_at.blank?

    followers = publication.publishable
                           .follows
                           .joins(:user)
                           .includes(:user)
                           .where(
                             'NOT EXISTS(SELECT *
                                         FROM publication_views
                                         WHERE publication_views.publication_id = :publication_id
                                           AND publication_views.user_id = users.id
                                         )',
                             publication_id: publication_id
                           )
                           .where.not(accepted_at: nil)

    followers.each do |follow|
      Notification.create(
        notification_type: 'new_publication',
        notifiable_type: 'Publication',
        notifiable_id: publication_id,
        user: follow.user
      )
    end
  end
end
