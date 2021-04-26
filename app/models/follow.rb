# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true, counter_cache: :follows_count
  belongs_to :user

  before_validation :auto_accepted

  after_create :start_following_notify!
  after_destroy :destroy_follow_notification!
  after_save :notify_accepted_change!

  FOLLOWABLE_LIST = %w[
    User
    Crag
    GuideBookPaper
    Gym
  ].freeze

  validates :followable_type, inclusion: { in: FOLLOWABLE_LIST }

  def accepted?
    accepted_at.present?
  end

  def accepted!
    self.accepted_at = Time.current
    save
  end

  def increment!
    self.views = views + 1
    save!
  end

  private

  def auto_accepted
    self.accepted_at = Time.current if %w[Crag Gym GuideBookPaper].include? followable_type
    return unless followable_type == 'User'

    target_user = User.find followable_id
    self.accepted_at = Time.current if target_user.public_profile?
  end

  def start_following_notify!
    return if followable_type != 'User'

    notification_type = accepted? ? 'new_follower' : 'request_for_follow_up'

    Notification.create(
      notification_type: notification_type,
      user_id: followable_id,
      notifiable_id: user.id,
      notifiable_type: 'User'
    )
  end

  def destroy_follow_notification!
    return if followable_type != 'User'

    followable.notifications
              .where(notifiable_type: 'User')
              .where(notifiable_id: user.id)
              .where(notification_type: %w[new_follower request_for_follow_up])
              .find_each(&:destroy)

    user.notifications
        .where(notifiable_type: 'User')
        .where(notifiable_id: followable.id)
        .where(notification_type: %w[subscribe_accepted])
        .find_each(&:destroy)
  end

  def notify_accepted_change!
    return if followable_type != 'User'
    return unless saved_change_to_accepted_at?

    Notification.create(
      notification_type: 'subscribe_accepted',
      user_id: user.id,
      notifiable_id: followable_id,
      notifiable_type: 'User'
    )
  end
end
