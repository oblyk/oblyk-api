# frozen_string_literal: true

module Api
  module V1
    module LogBooks
      class IndoorsController < ApiController
        before_action :protected_by_session
        before_action :set_ascents, only: %i[grades_chart simple_stats_by_gyms by_levels_chart]

        def figures
          render json: LogBook::Indoor::Figure.new(@current_user).figures, status: :ok
        end

        def climb_types_chart
          render json: LogBook::Indoor::Chart.new(@current_user).climb_type, status: :ok
        end

        def years_chart
          render json: LogBook::Indoor::Chart.new(@current_user).years, status: :ok
        end

        def months_chart
          render json: LogBook::Indoor::Chart.new(@current_user).months, status: :ok
        end

        def grades_chart
          render json: LogBook::Indoor::Chart.grade(@ascents), status: :ok
        end

        def by_levels_chart
          render json: LogBook::Indoor::Chart.by_levels(@ascents), status: :ok
        end

        def simple_stats_by_gyms
          stats_by_gyms = {}
          @ascents.find_each do |ascent|
            gym_key = "gym-#{ascent.gym_id}"

            # Init gym object and get chart
            unless stats_by_gyms[gym_key]
              stats_by_gyms[gym_key] = {
                gym: {
                  id: ascent.gym.id,
                  name: ascent.gym.name,
                  slug_name: ascent.gym.slug_name,
                  logo: ascent.gym.logo.attached? ? ascent.gym.logo_large_url : nil
                },
                ascents_count: 0,
                max_grade: { value: nil, text: nil },
                dates: { first: nil, last: nil },
                cumulative_height: 0,
                charts: []
              }
              grade_ascents = @ascents.select { |chart_ascent| chart_ascent.gym_id == ascent.gym_id && chart_ascent.max_grade_value.present? }
              by_levels_ascents = @ascents.select { |chart_ascent| chart_ascent.gym_id == ascent.gym_id && chart_ascent.color_system_line_id.present? }

              stats_by_gyms[gym_key][:charts] << { type: :grade_chart, chart: LogBook::Indoor::Chart.grade(grade_ascents) } if grade_ascents.size.positive?
              stats_by_gyms[gym_key][:charts] = stats_by_gyms[gym_key][:charts] + LogBook::Indoor::Chart.by_levels(by_levels_ascents) if by_levels_ascents.size.positive?
            end

            # Count number of ascents
            stats_by_gyms[gym_key][:ascents_count] += ascent.quantity
            stats_by_gyms[gym_key][:cumulative_height] += ascent.height * ascent.quantity if ascent.height.present?

            # Get first and last released_at
            stats_by_gyms[gym_key][:dates][:first] = ascent.released_at if stats_by_gyms[gym_key][:dates][:first].blank? || ascent.released_at < stats_by_gyms[gym_key][:dates][:first]
            stats_by_gyms[gym_key][:dates][:last] = ascent.released_at if stats_by_gyms[gym_key][:dates][:last].blank? || ascent.released_at > stats_by_gyms[gym_key][:dates][:last]

            # Get max grand value
            ascent.sections.each do |section|
              max_grade_value = stats_by_gyms[gym_key][:max_grade][:value]
              if section['grade_value'].present? && (max_grade_value.blank? || max_grade_value < section['grade_value'])
                stats_by_gyms[gym_key][:max_grade][:value] = section['grade_value']
                stats_by_gyms[gym_key][:max_grade][:text] = section['grade']
              end
            end
          end

          render json: stats_by_gyms.map { |stats_by_gyms| stats_by_gyms[1] }, status: :ok
        end

        private

        def set_ascents
          gym_ids = params.fetch(:gym_id, [])
          ascent_status = params.fetch(:ascent_status, [])
          climbing_types = params.fetch(:climbing_types, [])
          start_date = params.fetch(:start_date, '')
          end_date = params.fetch(:end_date, '')

          @ascents = @current_user.ascent_gym_routes.made.includes(color_system_line: :color_system)

          # Filter on gyms
          @ascents = @ascents.where(gym_id: gym_ids) if gym_ids.size.positive?

          # Filter by ascents status [project, sent, red_point, flash, onsight, repetition]
          @ascents = @ascents.where(ascent_status: ascent_status) if ascent_status.size.positive?

          # Filter by climbing types [sport_climbing, bouldering, pan]
          @ascents = @ascents.where(climbing_types: climbing_types) if climbing_types.size.positive?

          # Select ascent between dates
          @ascents = @ascents.where(released_at: [Date.parse(start_date), Date.parse(end_date)]) if start_date.present? && end_date.present?
        end
      end
    end
  end
end
