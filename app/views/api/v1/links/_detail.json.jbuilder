# frozen_string_literal: true

json.extract! link, :id, :name, :url, :description
json.creator do
  json.id link.user_id
  json.name link.user&.full_name
end
json.history do
  json.extract! link, :created_at, :updated_at
end
