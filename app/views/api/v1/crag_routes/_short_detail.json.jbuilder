# frozen_string_literal: true

json.extract! crag_route,
              :id,
              :name,
              :slug_name,
              :height,
              :open_year,
              :opener,
              :climbing_type,
              :sections_count,
              :max_bolt,
              :note,
              :note_count,
              :ascents_count
json.grade_to_s crag_route.grade_to_s
json.grade_gap do
  json.extract! crag_route,
                :max_grade_value,
                :min_grade_value,
                :max_grade_text,
                :min_grade_text
end
json.sector do
  json.id crag_route.crag_sector&.id
  json.name crag_route.crag_sector&.name
  json.slug_name crag_route.crag_sector&.slug_name
end
json.crag do
  json.id crag_route.crag.id
  json.name crag_route.crag.name
  json.slug_name crag_route.crag.slug_name
  json.country crag_route.crag.country
  json.region crag_route.crag.region
  json.city crag_route.crag.city
end