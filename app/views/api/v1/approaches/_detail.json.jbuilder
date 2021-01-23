# frozen_string_literal: true

json.extract! approach,
              :id,
              :description,
              :approach_type,
              :polyline,
              :length
json.walking_time approach.walking_time
json.crag do
  json.id approach.crag.id
  json.name approach.crag.name
  json.slug_name approach.crag.slug_name
end
json.creator do
  json.id approach.user_id
  json.name approach.user&.full_name
end
json.history do
  json.extract! approach, :created_at, :updated_at
end
