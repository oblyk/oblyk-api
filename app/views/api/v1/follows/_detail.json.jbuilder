# frozen_string_literal: true

json.extract! follow, :id, :followable_type, :followable_id
json.follower do
  json.id follow.user_id
  json.name follow.user&.full_name
end
json.history do
  json.extract! follow, :created_at, :updated_at
end
