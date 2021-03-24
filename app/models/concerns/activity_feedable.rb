# frozen_string_literal: true

module ActivityFeedable
  extend ActiveSupport::Concern

  included do
    after_save :save_feed!
    after_destroy :remove_feed
  end

  def save_feed!
    return if instance_of?(AscentCragRoute) && %w[project repetition].include?(ascent_status)
    return if instance_of?(Article) && unpublished?
    return if instance_of?(Photo) && illustrable_type == 'Article'

    AddInFeedJob.set(wait_until: DateTime.current + 10.seconds).perform_later(self)
  end

  private

  def remove_feed
    feed = Feed.find_by feedable_id: id, feedable_type: self.class.name
    return unless feed

    feed.destroy
  end
end
