# frozen_string_literal: true

json.extract! approach,
              :id,
              :description,
              :approach_type,
              :polyline,
              :path_metadata,
              :length
json.walking_time approach.walking_time
json.elevation do
  json.start approach.elevation_start
  json.end approach.elevation_end
  json.positive_drop approach.positive_drop
  json.negative_drop approach.negative_drop
end
json.crag do
  json.id approach.crag.id
  json.name approach.crag.name
  json.slug_name approach.crag.slug_name
end
json.creator do
  json.uuid approach.user&.uuid
  json.name approach.user&.full_name
  json.slug_name approach.user&.slug_name
end
json.history do
  json.extract! approach, :created_at, :updated_at
end
