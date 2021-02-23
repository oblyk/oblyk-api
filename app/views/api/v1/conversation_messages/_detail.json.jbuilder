# frozen_string_literal: true

json.id conversation_message.id
json.conversation_id conversation_message.conversation_id
json.body conversation_message.body

json.creator do
  json.uuid conversation_message.user.uuid
  json.name conversation_message.user.full_name
  json.slug_name conversation_message.user.slug_name
end

json.history do
  json.extract! conversation_message, :created_at, :updated_at
end
