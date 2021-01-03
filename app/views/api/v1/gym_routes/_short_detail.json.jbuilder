# frozen_string_literal: true

json.extract! gym_route,
              :id,
              :name,
              :height,
              :openers,
              :opened_at,
              :dismounted_at,
              :polyline,
              :hold_colors,
              :tag_colors,
              :sections,
              :grade_value_appreciation,
              :note,
              :note_count,
              :ascents_count,
              :sections_count,
              :gym_sector_id,
              :gym_grade_line_id,
              :points
json.points_to_s gym_route.points_to_s
json.grade_to_s gym_route.grade_to_s
json.identification_to_s gym_route.identification_to_s
json.thumbnail gym_route.thumbnail.attached? ? url_for(gym_route.thumbnail) : nil
json.gym_sector_name gym_route.gym_sector.name
json.grade_gap do
  json.extract! gym_route,
                :max_grade_value,
                :min_grade_value,
                :max_grade_text,
                :min_grade_text
end
json.gym_space do
  json.id gym_route.gym_space.id
  json.slug_name gym_route.gym_space.slug_name
end
json.gym do
  json.id gym_route.gym.id
  json.slug_name gym_route.gym.slug_name
end
