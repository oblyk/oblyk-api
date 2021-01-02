# frozen_string_literal: true

json.extract! gym_grade,
              :id,
              :name,
              :difficulty_system,
              :has_hold_color,
              :use_grade_system,
              :use_point_system,
              :use_point_division_system
json.next_grade_lines_order gym_grade.next_grade_lines_order

json.gym do
  json.id gym_grade.gym.id
  json.slug_name gym_grade.gym.slug_name
end

json.grade_lines do
  json.array! gym_grade.gym_grade_lines do |gym_grade_line|
    json.partial! 'api/v1/gym_grade_lines/detail', gym_grade_line: gym_grade_line
  end
end
