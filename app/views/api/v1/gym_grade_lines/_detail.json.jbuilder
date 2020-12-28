# frozen_string_literal: true

json.extract! gym_grade_line,
              :id,
              :name,
              :colors,
              :order,
              :grade_text,
              :grade_value,
              :points

json.gym_grade do
  json.id gym_grade_line.gym_grade.id
  json.slug_name gym_grade_line.gym_grade.name
end

json.gym do
  json.id gym_grade_line.gym.id
  json.slug_name gym_grade_line.gym.slug_name
end
