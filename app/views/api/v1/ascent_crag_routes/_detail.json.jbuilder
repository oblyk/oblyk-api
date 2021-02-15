# frozen_string_literal: true

json.extract! ascent_crag_route,
              :id,
              :ascent_status,
              :roping_status,
              :hardness_status,
              :attempt,
              :crag_route_id,
              :sections,
              :height,
              :note,
              :comment,
              :sections_count,
              :max_grade_value,
              :min_grade_value,
              :max_grade_text,
              :min_grade_text,
              :released_at,
              :private_comment
json.sections_done ascent_crag_route.sections_done
json.crag_route do
  json.id ascent_crag_route.crag_route.id
  json.name ascent_crag_route.crag_route.name
  json.slug_name ascent_crag_route.crag_route.slug_name
end
json.crag do
  json.id ascent_crag_route.crag.id
  json.name ascent_crag_route.crag.name
  json.slug_name ascent_crag_route.crag.slug_name
end
json.history do
  json.extract! ascent_crag_route, :created_at, :updated_at
end
