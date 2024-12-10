# frozen_string_literal: true

module LogBook
  module Outdoor
    class Figure
      attr_accessor :user, :filters

      def initialize(user, filters)
        @user = user
        @filters = filters
        @filtered_ascents =  @user.ascent_crag_routes.made.filtered(@filters)
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
        @filtered_ascents.maximum(:max_grade_value)
      end

      # for countries, regions and crags we don't apply the filters (this choice can be discussed)
      def countries_count
        @user.ascended_crags.distinct.count(:country)
      end

      def regions_count
        @user.ascended_crags.distinct.count(:region)
      end

      def crags_count
        @user.ascended_crags.distinct.count(:id)
      end
    end
  end
end

