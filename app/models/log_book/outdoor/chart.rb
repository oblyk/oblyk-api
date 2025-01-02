# frozen_string_literal: true

module LogBook
  module Outdoor
    class Chart
      def initialize(ascents)
        @ascents = ascents
        @uniq_ascents = ascents.uniq(&:crag_route_id)
      end

      def climb_type
        climb_counts = Hash.new(0)

        @uniq_ascents.each do |ascent|
          climb_counts[ascent.climbing_type] += 1 if Climb::CRAG_LIST.include?(ascent.climbing_type)
        end

        {
          datasets: [
            {
              data: Climb::CRAG_LIST.map { |type| climb_counts[type] },
              backgroundColor: Climb::CRAG_LIST.map { |type| Climb::COLOR[type] },
              label: 'climb_type'
            }
          ],
          labels: Climb::CRAG_LIST
        }
      end

      def grade
        grades = Hash[(1..54).step(2).map { |grade_value| [grade_value, { count: 0 }] }]

        @uniq_ascents.each do |ascent|
          next if ascent.max_grade_value.blank? || ascent.max_grade_value.zero?

          grade_value = ascent.max_grade_value
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

      def years
        return { datasets: [{ data: [] }], labels: [] } if @uniq_ascents.blank?

        years = Hash.new(0)

        @uniq_ascents.each do |ascent|
          next if ascent.released_at.blank?

          years[ascent.released_at.year] += 1
        end

        sorted_years = years.sort.to_h

        {
          datasets: [
            {
              data: sorted_years.values,
              backgroundColor: '#1565c0',
              label: 'number'
            }
          ],
          labels: sorted_years.keys
        }
      end

      def months
        return { datasets: [{ data: [] }], labels: [] } if @uniq_ascents.blank?

        dates = Hash.new(0)

        @uniq_ascents.each do |ascent|
          next if ascent.released_at.blank?
          dates[ascent.released_at.strftime('%Y-%m')] += 1
        end

        sorted_dates = dates.sort.to_h

        {
          datasets: [
            {
              data: sorted_dates.values,
              backgroundColor: '#1565c0',
              label: 'number'
            }
          ],
          labels: sorted_dates.keys
        }
      end

      def evolution_by_year
        return { datasets: [{ data: [] }], labels: [] } if @ascents.blank?

        years = Hash.new { |hash, year| hash[year] = Hash.new(0) }

        @ascents.each do |ascent|
          next if ascent.released_at.blank? || ascent.max_grade_value.blank?

          year = ascent.released_at.year
          climbing_type = ascent.climbing_type.to_sym
          years[year][climbing_type] = [years[year][climbing_type], ascent.max_grade_value].max
        end

        sorted_years = years.keys.sort

        datasets = Climb::CRAG_LIST.map do |climbing_type|
          label = climbing_type.to_sym
          next unless years.values.sum { |year_data| year_data[label] }.positive?

          {
            data: sorted_years.map { |year| years[year][label] },
            borderColor: Climb::COLOR[climbing_type],
            fill: false,
            label: climbing_type
          }
        end

        {
          datasets: datasets.compact,
          labels: sorted_years
        }
      end
    end
  end
end

