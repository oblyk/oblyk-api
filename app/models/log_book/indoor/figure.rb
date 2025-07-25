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
          max_grade_value: max_grad_value,
          last_28_days: {
            sessions: climbing_sessions_count(since_28_days: true),
            gyms: gyms_count(since_28_days: true),
            ascents: ascents_count(since_28_days: true)
          }
        }
      end

      private

      def ascents_count(since_28_days: false)
        ascents = @user.ascent_gym_routes.made
        ascents = ascents.where('ascents.released_at >= ?', Date.current - 28.days) if since_28_days
        ascents.sum(:quantity)
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

      def climbing_sessions_count(since_28_days: false)
        climbing_sessions = @user.climbing_sessions.where('EXISTS(SELECT * FROM ascents WHERE gym_id IS NOT NULL AND climbing_session_id = climbing_sessions.id)')
        climbing_sessions = climbing_sessions.where('climbing_sessions.session_date >= ?', Date.current - 28.days) if since_28_days
        climbing_sessions.count
      end

      def gyms_count(since_28_days: false)
        gyms = @user.ascended_gyms
        gyms = gyms.where('ascents.released_at >= ?', Date.current - 28.days) if since_28_days
        gyms.distinct.count
      end
    end
  end
end

