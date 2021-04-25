# frozen_string_literal: true

class ConversationUser < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  def read!
    update_attribute(:last_read_at, DateTime.current)
    mark_as_read_notifications!
  end

  private

  def mark_as_read_notifications!
    notifications = user.notifications
                        .unread
                        .where(notifiable_type: 'ConversationMessage')
    notifications.each do |notification|
      notification.read! if notification.notifiable.conversation == conversation
    end
  end
end
