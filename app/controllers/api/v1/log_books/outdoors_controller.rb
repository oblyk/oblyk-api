# frozen_string_literal: true

module Api
  module V1
    module LogBooks
      class OutdoorsController < ApiController
        before_action :protected_by_session
        before_action :set_user

        def figures
          render json: LogBook::Outdoor::Figure.new(@user).figures, status: :ok
        end

        def climb_types_chart
          render json: LogBook::Outdoor::Chart.new(@user).climb_type, status: :ok
        end

        def grades_chart
          render json: LogBook::Outdoor::Chart.new(@user).grade, status: :ok
        end

        def years_chart
          render json: LogBook::Outdoor::Chart.new(@user).years, status: :ok
        end

        def months_chart
          render json: LogBook::Outdoor::Chart.new(@user).months, status: :ok
        end

        def evolutions_chart
          render json: LogBook::Outdoor::Chart.new(@user).evolution_by_year, status: :ok
        end

        def daily_ascents
          dates = []
          ascents_by_days = {}
          today = Date.current
          min_ascent_date = AscentCragRoute.made.where(user: @user).minimum(:released_at)
          max_ascent_date = AscentCragRoute.made.where(user: @user).maximum(:released_at)

          if min_ascent_date.nil? || max_ascent_date.nil?
            render json: {}, status: :ok
          else
            # x years ago
            dates_range = (min_ascent_date.year..max_ascent_date.year)
            dates_range.each do |year|
              dates << Date.new(year, today.month, today.day)
            end
            dates << today - 1.week # one week ago
            dates << today - 1.month # one month ago
            dates << today - 6.months # 6 months ago

            ascents = AscentCragRoute.made.where(user: @user).where('DATE(released_at) IN(?)', dates).order(:released_at)
            ascents.each do |ascent|
              ascents_by_days[ascent.released_at.to_date] ||= {}
              ascents_by_days[ascent.released_at.to_date]["crag-#{ascent.crag.id}"] ||= {
                crag: ascent.crag.summary_to_json,
                date: ascent.released_at.to_date,
                ascents: []
              }
              ascents_by_days[ascent.released_at.to_date]["crag-#{ascent.crag.id}"][:ascents] << ascent.summary_to_json
            end
            render json: ascents_by_days, status: :ok
          end
        end

        def ascents_of_crag
          ascents = @user.ascent_crag_routes
                         .joins(:crag_route)
                         .where(crag_routes: { crag_id: params[:crag_id] })
                         .order(min_grade_value: :desc)

          ascent_routes = []
          ascents.each do |ascent|
            ascent_route = ascent.summary_to_json
            ascent_route[:crag_route][:grade_gap][:max_grade_value] = ascent.max_grade_value
            ascent_route[:crag_route][:grade_gap][:min_grade_value] = ascent.min_grade_value
            ascent_route[:crag_route][:grade_gap][:max_grade_text] = ascent.max_grade_text
            ascent_route[:crag_route][:grade_gap][:min_grade_text] = ascent.min_grade_text
            ascent_routes << ascent_route
          end
          render json: ascent_routes, status: :ok
        end

        private

        def set_user
          @user = @current_user
        end
      end
    end
  end
end
