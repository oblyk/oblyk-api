# frozen_string_literal: true

class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    conversation = current_user.conversations.find params[:conversation_id]
    stream_from "conversations_#{conversation.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
