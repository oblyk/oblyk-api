# frozen_string_literal: true

module LogBook
  module Outdoor
    class Figure
      attr_accessor :user

      # filters parameter is an instance of CragFilteredAscents
      def initialize(ascents)
        @ascents = ascents
        @crags = []
        ascents.each do |ascent|
          @crags << ascent.crag_route.crag
        end
      end

      def figures
        {
          countries: countries_count,
          regions: regions_count,
          crags: crags_count,
          ascents: ascents_count,
          meters: sum_meters,
          max_grade_value: max_grad_value
        }
      end

      private

      def ascents_count
        @ascents.count
      end

      def sum_meters
        @ascents.sum do |ascent|
          # Extract the section heights, ignoring nil values
          sections_heights = ascent.sections.map { |section| section['height'] }.compact
          # If sections have heights, sum them, otherwise fallback to the ascent's height
          sections_heights.any? ? sections_heights.sum : (ascent.height || 0)
        end
      end

      def max_grad_value
        @ascents.map(&:max_grade_value).compact.max
      end

      def countries_count
        @crags.map(&:country).uniq.size
      end

      def regions_count
        @crags.map(&:region).uniq.size
      end

      def crags_count
        @crags.map(&:id).uniq.size
      end
    end
  end
end

