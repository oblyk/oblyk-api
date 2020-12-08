# frozen_string_literal: true

json.array! @gym_grades do |gym_grade|
  json.partial! 'api/v1/gym_grades/detail', gym_grade: gym_grade
end
