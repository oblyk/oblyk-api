# frozen_string_literal: true

json.extract! gym_sector,
              :id,
              :name,
              :description,
              :group_sector_name,
              :climbing_type,
              :height,
              :polygon,
              :gym_space_id,
              :gym_grade_id,
              :can_be_more_than_one_pitch
json.gym do
  json.id gym_sector.gym.id
  json.slug_name gym_sector.gym.slug_name
end
json.gym_space do
  json.id gym_sector.gym_space.id
  json.slug_name gym_sector.gym_space.slug_name
end
