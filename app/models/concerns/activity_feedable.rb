# frozen_string_literal: true

module ActivityFeedable
  extend ActiveSupport::Concern

  included do
    after_create :save_feed!
    after_update :save_feed!
    after_destroy :remove_feed
  end

  def save_feed!
    if instance_of?(AscentCragRoute)
      initialize_feed.save if %w[project repetition].exclude? ascent_status
    else
      initialize_feed.save
    end

  end

  private

  def initialize_feed
    feed = Feed.find_or_initialize_by(
      feedable_id: id,
      feedable_type: self.class.name
    )
    feed.feed_object = summary_to_json
    feed.latitude =  latitude if defined?(latitude)
    feed.longitude = longitude if defined?(longitude)
    feed.posted_at ||= created_at
    feed.parent_id = feed_parent_id
    feed.parent_type = feed_parent_type
    feed.parent_object = feed_parent_object
    feed
  end

  def remove_feed
    feed = Feed.find_by feedable_id: id, feedable_type: self.class.name
    return unless feed

    feed.destroy
  end
end
