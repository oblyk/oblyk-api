# frozen_string_literal: true

json.extract! gym_grade,
              :id,
              :name,
              :difficulty_system,
              :has_hold_color
json.next_grade_lines_order gym_grade.next_grade_lines_order

json.grade_lines do
  json.array! gym_grade.gym_grade_lines do |gym_grade_line|
    json.id gym_grade_line.id
    json.order gym_grade_line.order
    json.name gym_grade_line.name
    json.colors gym_grade_line.colors
    json.grade_text gym_grade_line.grade_text
    json.grade_value gym_grade_line.grade_value
  end
end
