# frozen_string_literal: true

module LogBook
  module Outdoor
    class Figure
      attr_accessor :user

      def initialize(user)
        @user = user
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
        @user.ascent_crag_routes.made.count
      end

      def sum_meters
        @user.ascent_crag_routes.made.sum(:height)
      end

      def max_grad_value
        @user.ascent_crag_routes.made.maximum(:max_grade_value)
      end

      def countries_count
        @user.ascended_crags.distinct.count(:code_country)
      end

      def regions_count
        @user.ascended_crags.distinct.count(:region)
      end

      def crags_count
        @user.ascended_crags.distinct.count
      end
    end
  end
end

