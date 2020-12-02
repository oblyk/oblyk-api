# frozen_string_literal: true

json.id conversation.id
json.conversation_users do
  json.array! conversation.users do |user|
    json.id user.id
    json.name user.full_name
  end
end
json.conversation_message_count conversation.conversation_messages.count

json.history do
  json.extract! conversation, :created_at, :updated_at
end
