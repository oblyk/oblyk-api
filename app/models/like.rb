# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: :likes_count, touch: true

  after_create :create_notification!
  after_destroy :destroy_notification!

  LIKEABLE_TYPES = %w[GymRoute Comment Photo Video Article].freeze
  USER_NOTIFIABLE_TYPES = %w[Comment Photo Video].freeze

  def summary_to_json
    {
      id: id,
      likeable_type: likeable_type,
      likeable_id: likeable_id,
      likeable_likes_count: likeable.likes.count
    }
  end

  def detail_to_json
    summary_to_json
  end

  private

  def create_notification!
    return unless USER_NOTIFIABLE_TYPES.include? likeable_type

    Notification.create(
      notification_type: 'new_like',
      notifiable_type: 'Like',
      notifiable_id: id,
      user: likeable.user
    )
  end

  def destroy_notification!
    return unless USER_NOTIFIABLE_TYPES.include? likeable_type

    notification = Notification.find_by(
      notification_type: 'new_like',
      notifiable_type: 'Like',
      notifiable_id: id,
      user: likeable.user
    )
    notification&.destroy
  end
end
