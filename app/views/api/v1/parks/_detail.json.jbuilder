# frozen_string_literal: true

json.extract! park,
              :id,
              :description,
              :latitude,
              :longitude
json.crag do
  json.id park.crag.id
  json.name park.crag.name
  json.slug_name park.crag.slug_name
end
json.creator do
  json.id park.user_id
  json.name park.user&.full_name
end
json.history do
  json.extract! park, :created_at, :updated_at
end
