# frozen_string_literal: true

module LogBook
  module Outdoor
    class Figure
      attr_accessor :user

      # filters parameter is an instance of CragAscentFilters
      def initialize(user, filters)
        @user = user
        @filtered_ascents = filters.filtered_ascents_array
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
        @filtered_ascents.count
      end

      def sum_meters
        @filtered_ascents.sum do |ascent|
          # Extract the section heights, ignoring nil values
          sections_heights = ascent.sections.map { |section| section['height'] }.compact
          # If sections have heights, sum them, otherwise fallback to the ascent's height
          sections_heights.any? ? sections_heights.sum : (ascent.height || 0)
        end
      end

      def max_grad_value
        @filtered_ascents.map(&:max_grade_value).compact.max
      end

      def countries_count
        @filtered_ascents.map(&:crag).map(&:country).uniq.count
      end

      def regions_count
        @filtered_ascents.map(&:crag).map(&:region).uniq.count
      end

      def crags_count
        @filtered_ascents.map(&:crag).uniq.count
      end
    end
  end
end

