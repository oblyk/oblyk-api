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
  json.difficulty_system gym_grade_line.gym_grade.difficulty_system
  json.use_grade_system gym_grade_line.gym_grade.use_grade_system
  json.use_point_system gym_grade_line.gym_grade.use_point_system
  json.use_point_division_system gym_grade_line.gym_grade.use_point_division_system
end

json.gym do
  json.id gym_grade_line.gym.id
  json.slug_name gym_grade_line.gym.slug_name
end
