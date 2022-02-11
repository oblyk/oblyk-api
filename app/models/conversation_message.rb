# frozen_string_literal: true

class ConversationMessage < ApplicationRecord
  include StripTagable

  belongs_to :conversation
  belongs_to :user

  before_validation :init_posted_at
  after_create :update_last_message_at!
  after_create :update_last_read!
  after_create :notify!

  validates :body, presence: true

  def conversation_user
    ConversationUser.find_by conversation: conversation, user: user
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      conversation_id: conversation_id,
      body: body,
      posted_at: posted_at,
      creator: user&.summary_to_json,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def notify!
    other_user_in_conversation = conversation.conversation_users.where.not(user: user)
    other_user_in_conversation.each do |conversation_user|
      similar_notifications = conversation_user.user
                                               .notifications
                                               .unread
                                               .where(notifiable_type: self.class.name)
      have_been_notified = false
      similar_notifications.each do |notification|
        if notification.notifiable.conversation_id == conversation_id
          have_been_notified = true
          break
        end
      end

      next if have_been_notified

      Notification.create(
        notification_type: 'new_message',
        user: conversation_user.user,
        notifiable: self
      )
    end
  end

  def init_posted_at
    self.posted_at ||= Time.current
  end

  def update_last_message_at!
    conversation.update_last_message_at!
  end

  def update_last_read!
    conversation_user.read!
  end
end
