# frozen_string_literal: true

class Notification < ApplicationRecord
  include Readable

  NOTIFIABLE_TYPE_LIST = %w[User ConversationMessage Like Comment Publication].freeze
  NOTIFICATION_TYPE_LIST = %w[
    new_message
    new_follower
    subscribe_accepted
    request_for_follow_up
    new_publication
    new_like
    new_reply
  ].freeze

  EMAILABLE_NOTIFICATION_LIST = %w[
    new_message
    new_publication
    request_for_follow_up
    new_article
  ].freeze

  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :notification_type, presence: true
  validates :notifiable_type, inclusion: { in: NOTIFIABLE_TYPE_LIST.freeze }
  validates :notification_type, inclusion: { in: NOTIFICATION_TYPE_LIST }

  default_scope { order(posted_at: :desc) }

  before_validation :set_posted_at
  after_create :send_email_notification
  after_save :broadcast_notification

  def name
    if notifiable_type == 'User'
      notifiable.first_name
    elsif notifiable_type == 'Article'
      notifiable.name
    elsif %w[ConversationMessage Like Comment].include? notifiable_type
      notifiable.user.first_name
    elsif notifiable_type == 'Publication'
      notifiable.publishable.name
    end
  end

  def app_path
    if notification_type == 'new_message'
      notifiable.app_path
    elsif %w[new_follower subscribe_accepted request_for_follow_up].include? notification_type
      notifiable.app_path
    elsif notification_type == 'new_like'
      notifiable.likeable.app_path
    elsif notification_type == 'new_reply'
      notifiable.app_path
    elsif notification_type == 'new_publication'
      notifiable.app_path
    end
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    parent_object = %w[ConversationMessage Like Comment].include?(notifiable_type) ? notifiable.user.summary_to_json : nil
    {
      id: id,
      notification_type: notification_type,
      notifiable_type: notifiable_type,
      notifiable_id: notifiable_id,
      posted_at: posted_at,
      read_at: read_at,
      notifiable_object: notifiable.summary_to_json,
      parent_object: parent_object,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def set_posted_at
    self.posted_at ||= Time.current
  end

  def send_email_notification
    return if notification_type == 'new_publication' && notifiable_type == 'Publication' # Send with SendPublicationsEmailsJob
    return if user.email_notifiable_list.blank?
    return unless user.email_notifiable_list&.include?(notification_type)

    EmailNotificationWorker.perform_in(5.minutes, id)
  end

  def broadcast_notification
    ActionCable.server.broadcast "notification_#{user.id}", user.notifications.unread.count.positive?
  end
end
