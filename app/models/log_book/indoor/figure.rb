# frozen_string_literal: true

module LogBook
  module Indoor
    class Figure
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def figures
        {
          countries: countries_count,
          regions: regions_count,
          gyms: gyms_count,
          ascents: ascents_count,
          meters: sum_meters,
          max_grade_value: max_grad_value
        }
      end

      private

      def ascents_count
        @user.ascent_gym_routes.made.sum(:quantity)
      end

      def sum_meters
        @user.ascent_gym_routes.made.sum('height * quantity')
      end

      def max_grad_value
        @user.ascent_gym_routes.made.maximum(:max_grade_value)
      end

      def countries_count
        @user.ascended_gyms.distinct.count(:code_country)
      end

      def regions_count
        @user.ascended_gyms.distinct.count(:region)
      end

      def gyms_count
        @user.ascended_gyms.distinct.count
      end
    end
  end
end

