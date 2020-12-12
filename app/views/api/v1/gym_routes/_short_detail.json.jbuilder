# frozen_string_literal: true

json.extract! gym_route,
              :id,
              :name,
              :height,
              :favorite,
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
              :gym_grade_line_id
json.grade_gap do
  json.extract! gym_route,
                :max_grade_value,
                :min_grade_value,
                :max_grade_text,
                :min_grade_text
end
