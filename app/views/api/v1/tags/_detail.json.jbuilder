# frozen_string_literal: true

json.extract! tag, :id, :name
json.creator do
  json.id tag.user_id
  json.name tag.user&.full_name
end
json.history do
  json.extract! tag, :created_at, :updated_at
end
