# frozen_string_literal: true

json.extract! tag, :id, :name
json.creator do
  json.uuid tag.user&.uuid
  json.name tag.user&.full_name
  json.slug_name tag.user&.slug_name
end
json.history do
  json.extract! tag, :created_at, :updated_at
end
