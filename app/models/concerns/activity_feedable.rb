# frozen_string_literal: true

module ActivityFeedable
  extend ActiveSupport::Concern

  included do
    after_create_commit :save_feed!
    after_update_commit :save_feed!
    after_destroy_commit :remove_feed
  end

  def save_feed!
    feedable = ENV.fetch('FEEDABLE', 'false')
    return if feedable == 'false'

    return if has_attribute?(:deleted_at) && deleted_at.present?

    return if instance_of?(AscentCragRoute) && %w[project repetition].include?(ascent_status)
    return if instance_of?(Article) && unpublished?
    return if instance_of?(Photo) && %w[Article Newsletter].include?(illustrable_type)
    return if instance_of?(Video) && %w[GymRoute].include?(viewable_type)

    AddInFeedWorker.perform_in(10.seconds, self.class.name, id)
  end

  private

  def remove_feed
    feed = Feed.find_by feedable_id: id, feedable_type: self.class.name
    return unless feed

    feed.destroy
  end
end
