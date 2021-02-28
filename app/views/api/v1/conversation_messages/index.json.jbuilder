# frozen_string_literal: true

json.array! @conversation_messages do |conversation_message|
  json.partial! 'api/v1/conversation_messages/detail', conversation_message: conversation_message
end
