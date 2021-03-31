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
  json.partial! 'api/v1/crag_routes/short_detail', crag_route: ascent_crag_route.crag_route
end
json.crag do
  json.id ascent_crag_route.crag.id
  json.name ascent_crag_route.crag.name
  json.slug_name ascent_crag_route.crag.slug_name
end
json.ascent_users do
  json.array! ascent_crag_route.ascent_users do |ascent_user|
    json.id ascent_user.id
    json.user do
      json.partial! 'api/v1/users/short_detail', user: ascent_user.user
    end
  end
end
json.history do
  json.extract! ascent_crag_route, :created_at, :updated_at
end
