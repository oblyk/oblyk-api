# frozen_string_literal: true

module LogBook
  module Indoor
    class Chart
      def self.grade(ascents)
        grades = {}
        54.times do |grade_value|
          next unless grade_value.even?

          grades[grade_value + 1] = { count: 0 }
        end

        ascents.each do |ascent|
          next if ascent.min_grade_value.blank? || ascent.min_grade_value.zero?

          grade_value = ascent.min_grade_value
          grade_value -= 1 if grade_value.even?

          grades[grade_value][:count] += 1
        end

        {
          datasets: [
            {
              data: grades.map { |grade| grade[1][:count] },
              backgroundColor: grades.map { |grade| Grade.value_color(grade[0] - 1) },
              label: 'number'
            }
          ],
          labels: grades.map { |grade| grade[0] }
        }
      end

      def self.by_levels(ascents)
        charts = []
        ascents.group_by { |ascent| ascent.color_system_line.color_system.id }.each do |_key, ascents_in_level|
          color_system = ascents_in_level.first.color_system_line.color_system
          background = []
          labels = []
          data = []
          color_system.color_system_lines.each do |color_system_line|
            background << color_system_line.hex_color
            labels << color_system_line.order
            data << ascents_in_level.count { |ascent| ascent.color_system_line_id == color_system_line.id }
          end

          charts << {
            type: 'level_chart',
            color_system: color_system.detail_to_json,
            chart: {
              datasets: [
                {
                  data: data,
                  backgroundColor: background,
                  label: 'level'
                }
              ],
              labels: labels
            }
          }
        end
        charts
      end
    end
  end
end
