# frozen_string_literal: true

json.extract! link, :id, :name, :url, :description
json.creator do
  json.uuid link.user&.uuid
  json.name link.user&.full_name
  json.slug_name link.user&.slug_name
end
json.history do
  json.extract! link, :created_at, :updated_at
end
