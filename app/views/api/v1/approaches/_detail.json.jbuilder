# frozen_string_literal: true

json.extract! approach,
              :id,
              :description,
              :polyline,
              :length
json.creator do
  json.id approach.user_id
  json.name approach.user&.full_name
end
json.history do
  json.extract! approach, :created_at, :updated_at
end
