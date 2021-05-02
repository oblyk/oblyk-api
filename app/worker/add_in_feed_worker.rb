# frozen_string_literal: true

class AddInFeedWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(class_object, class_id)
    feedable_object = class_object.constantize.find class_id

    feed = Feed.find_or_initialize_by(
      feedable_id: feedable_object.id,
      feedable_type: feedable_object.class.name
    )
    feed.feed_object = feedable_object.summary_to_json
    feed.latitude =  feedable_object.latitude if defined?(feedable_object.latitude)
    feed.longitude = feedable_object.longitude if defined?(feedable_object.longitude)
    feed.posted_at = defined?(feedable_object.published_at) ? feedable_object.published_at : feedable_object.created_at
    feed.parent_id = feedable_object.feed_parent_id
    feed.parent_type = feedable_object.feed_parent_type
    feed.parent_object = feedable_object.feed_parent_object
    feed.save
  end
end
