# frozen_string_literal: true

json.id conversation.id
json.conversation_users do
  json.array! conversation.users do |user|
    json.uuid user.uuid
    json.name user.full_name
    json.slug_name user.slug_name
  end
end
json.conversation_message_count conversation.conversation_messages.count

json.history do
  json.extract! conversation, :created_at, :updated_at
end
