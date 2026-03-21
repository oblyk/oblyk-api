# frozen_string_literal: true

class PublicationViewsMapper
  attr_accessor :publications, :user

  def initialize(publications, user)
    self.publications = publications
    self.user = user
  end

  def map_publications
    return publications unless user

    if publications.instance_of? Publication
      self.publications = [publications]
      mapper.first
    else
      mapper
    end
  end

  private

  def mapper
    publication_ids = publications.reject { |publication| publication.published_at.blank? || publication.published_at < Date.current - 3.months }.map(&:id)
    publication_views = PublicationView.where(user_id: user.id, publication_id: publication_ids)

    # If no publication is already viewed, save and return publications
    if publication_views.size.zero?
      save_views(publication_ids)
      return publications
    end

    publication_views = publication_views.group_by(&:publication_id)
    unviewed_publications = []
    publications_view_ids = publication_views.map(&:first)

    publications.each do |publication|
      if publications_view_ids.include?(publication.id) || publication.published_at < Date.current - 3.months
        publication.viewed = true
      else
        unviewed_publications << publication.id
      end
    end

    # Save un viewed publication for current user
    save_views(unviewed_publications) if unviewed_publications.size.positive?

    publications
  end

  def save_views(publication_ids)
    publication_views = []
    publication_ids.each do |publication_id|
      publication_views << PublicationView.new(publication_id: publication_id, user: user, viewed_at: Time.current)
    end
    publication_views.each(&:save)

    # Destroy all related notification
    Notification.where(notification_type: 'new_publication',
                       notifiable_type: 'Publication',
                       notifiable_id: publication_ids,
                       user: user)
                .destroy_all
  end
end
