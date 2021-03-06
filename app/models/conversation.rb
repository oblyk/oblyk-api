# frozen_string_literal: true

class Conversation < ApplicationRecord
  has_many :conversation_messages
  has_many :conversation_users
  has_many :users, through: :conversation_users

  accepts_nested_attributes_for :conversation_users

  def same_conversation
    concat_user = conversation_users.sort_by(&:user_id)
    same_conversations = ConversationUser.select('conversation_id, GROUP_CONCAT(user_id ORDER BY user_id) AS concat_users')
                                         .group(:conversation_id)
                                         .having('concat_users = ?', concat_user.pluck(:user_id).join(','))
    return unless same_conversations.to_a.size.positive?

    Conversation.find same_conversations.first.conversation_id
  end

  def update_last_message_at!
    last_message_date = conversation_messages.maximum(:posted_at)
    update_attribute(:last_message_at, last_message_date)
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      conversation_users: conversation_users.map do |conversation_user|
        conversation_user.user.summary_to_json.merge({ last_read_at: conversation_user.last_read_at })
      end,
      last_message: {
        body: conversation_messages.last&.body,
        user_uuid: conversation_messages.last&.user&.uuid,
        user_name: conversation_messages.last&.user&.first_name,
        posted_at: conversation_messages.last&.posted_at
      },
      last_message_at: last_message_at,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
