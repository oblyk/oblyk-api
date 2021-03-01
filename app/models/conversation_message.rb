# frozen_string_literal: true

class ConversationMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  before_validation :init_posted_at
  after_create :update_last_message_at!
  after_create :update_last_read!

  validates :body, presence: true

  def conversation_user
    ConversationUser.find_by conversation: conversation, user: user
  end

  def show_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/conversation_messages/show.json',
        assigns: { conversation_message: self }
      )
    )
  end

  private

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
