# frozen_string_literal: true

json.id comment.id
json.body comment.body
json.creator do
  json.id comment.user_id
  json.slug_name comment.user&.slug_name
  json.name comment.user&.full_name
end
json.history do
  json.extract! comment, :created_at, :updated_at
end
