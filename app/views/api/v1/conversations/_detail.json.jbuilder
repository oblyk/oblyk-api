# frozen_string_literal: true

json.id conversation.id
json.conversation_users do
  json.array! conversation.conversation_users do |conversation_user|
    json.last_read_at conversation_user.last_read_at
    json.uuid conversation_user.user.uuid
    json.name conversation_user.user.full_name
    json.slug_name conversation_user.user.slug_name
    json.avatar_thumbnail_url conversation_user.user.avatar_thumbnail_url
  end
end
json.conversation_message_count conversation.conversation_messages.count
json.last_message do
  json.body conversation.conversation_messages.last&.body
  json.user_uuid conversation.conversation_messages.last&.user&.uuid
  json.user_name conversation.conversation_messages.last&.user&.first_name
  json.posted_at conversation.conversation_messages.last&.posted_at
end
json.last_message_at conversation.last_message_at
json.history do
  json.extract! conversation, :created_at, :updated_at
end
