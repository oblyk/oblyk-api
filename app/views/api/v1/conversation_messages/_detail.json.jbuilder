# frozen_string_literal: true

json.id conversation_message.id
json.id conversation_message.conversation_id
json.body conversation_message.body

json.history do
  json.extract! conversation_message, :created_at, :updated_at
end
