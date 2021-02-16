# frozen_string_literal: true

module LogBook
  module Outdoor
    class Chart
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def climb_type
        sport_climbing = 0
        bouldering = 0
        multi_pitch = 0
        trad_climbing = 0
        aid_climbing = 0
        deep_water = 0
        via_ferrata = 0

        @user.ascent_crag_routes.made.each do |ascent|
          sport_climbing += 1 if ascent.climbing_type == 'sport_climbing'
          bouldering += 1 if ascent.climbing_type == 'bouldering'
          multi_pitch += 1 if ascent.climbing_type == 'multi_pitch'
          trad_climbing += 1 if ascent.climbing_type == 'trad_climbing'
          aid_climbing += 1 if ascent.climbing_type == 'aid_climbing'
          deep_water += 1 if ascent.climbing_type == 'deep_water'
          via_ferrata += 1 if ascent.climbing_type == 'via_ferrata'
        end

        {
          datasets: [
            {
              data: [
                sport_climbing,
                bouldering,
                multi_pitch,
                trad_climbing,
                aid_climbing,
                deep_water,
                via_ferrata
              ],
              backgroundColor: [
                '#3a71c7', # Sport climbing
                '#ffcb00', # Bouldering
                '#ff5656', # Multi pitch
                '#e92b2b', # Trad climbing
                '#d40000', # Aid climbing
                '#86ccdd', # Deep water
                '#3cc770' # Via ferrata
              ],
              label: 'climb_type'
            }
          ],
          labels: %w[sport_climbing bouldering multi_pitch trad_climbing aid_climbing deep_water via_ferrata]
        }
      end

      def grade
        grades = {}
        54.times do |grade_value|
          next unless grade_value.even?

          grades[grade_value + 1] = { count: 0 }
        end

        @user.ascent_crag_routes.made.each do |ascent|
          next if ascent.min_grade_value.blank?

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
    end
  end
end
