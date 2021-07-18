# frozen_string_literal: true

json.extract! ascent_gym_route,
              :id,
              :ascent_status,
              :hardness_status,
              :gym_route_id,
              :gym_id,
              :gym_grade_id,
              :gym_grade_level,
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
json.sections_done ascent_gym_route.sections_done
if ascent_gym_route.gym_route
  json.gym_route do
    json.partial! 'api/v1/gym_routes/short_detail', gym_route: ascent_gym_route.gym_route
  end
end
json.gym do
  json.id ascent_gym_route.gym.id
  json.name ascent_gym_route.gym.name
  json.slug_name ascent_gym_route.gym.slug_name
end
json.history do
  json.extract! ascent_gym_route, :created_at, :updated_at
end
json.user do
  json.uuid ascent_gym_route.user.uuid
  json.first_name ascent_gym_route.user.first_name
  json.last_name ascent_gym_route.user.last_name
  json.slug_name ascent_gym_route.user.slug_name
end

