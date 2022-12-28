# frozen_string_literal: true

module LogBook
  module Indoor
    class Chart

      def initialize(user)
        @user = user
      end

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

          grades[grade_value][:count] += ascent.quantity
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
        ascents.group_by { |ascent| ascent.color_system_line&.color_system&.id }.each do |_key, ascents_in_level|
          next unless ascents_in_level.first.color_system_line

          color_system = ascents_in_level.first.color_system_line.color_system
          background = []
          labels = []
          data = []
          color_system.color_system_lines.each do |color_system_line|
            background << color_system_line.hex_color
            labels << color_system_line.order
            data << ascents_in_level.sum { |ascent| ascent.color_system_line_id == color_system_line.id ? ascent.quantity : 0 }
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

      def climb_type
        sport_climbing = 0
        bouldering = 0
        pan = 0

        @user.ascent_gym_routes.made.each do |ascent|
          sport_climbing += ascent.quantity if ascent.climbing_type == 'sport_climbing'
          bouldering += ascent.quantity if ascent.climbing_type == 'bouldering'
          pan += ascent.quantity if ascent.climbing_type == 'pan'
        end

        {
          datasets: [
            {
              data: [
                sport_climbing,
                bouldering,
                pan
              ],
              backgroundColor: [
                Climb::COLOR[Climb::SPORT_CLIMBING],
                Climb::COLOR[Climb::BOULDERING],
                Climb::COLOR[Climb::PAN]
              ],
              label: 'climb_type'
            }
          ],
          labels: %w[sport_climbing bouldering pan]
        }
      end

      def years
        min_year = @user.ascent_gym_routes.made.minimum(:released_at).year
        max_year = @user.ascent_gym_routes.made.maximum(:released_at).year
        years = {}

        (min_year..max_year).each do |year|
          years[year] = { count: 0 }
        end

        @user.ascent_gym_routes.made.order(:released_at).each do |ascent|
          next if ascent.released_at.blank?

          years[ascent.released_at.year][:count] += ascent.quantity
        end

        {
          datasets: [
            {
              data: years.map { |year| year[1][:count] },
              backgroundColor: '#31994e',
              label: 'number'
            }
          ],
          labels: years.map { |year| year[0] }
        }
      end

      def months
        min_date = @user.ascent_gym_routes.made.minimum(:released_at)
        max_date = @user.ascent_gym_routes.made.maximum(:released_at)
        dates = {}

        (min_date..max_date).each do |date|
          dates[date.strftime('%Y-%m')] ||= { count: 0 }
        end

        @user.ascent_gym_routes.made.order(:released_at).each do |ascent|
          next if ascent.released_at.blank?

          dates[ascent.released_at.strftime('%Y-%m')][:count] += ascent.quantity
        end

        {
          datasets: [
            {
              data: dates.map { |date| date[1][:count] },
              backgroundColor: '#31994e',
              label: 'number'
            }
          ],
          labels: dates.map { |date| date[0] }
        }
      end
    end
  end
end
