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

end
