# frozen_string_literal: true

module Api
  module V1
    module LogBooks
      class OutdoorsController < ApiController
        before_action :protected_by_session
        before_action :set_user
        before_action :set_ascents, only: [:stats, :ascended_crag_routes]
        before_action :set_stats_list, only: [:stats]

        def stats
          # set all stats charts, figures and lists from filtered ascents
          charts = LogBook::Outdoor::Chart.new(@ascents)
          stats = {}
          stats[:figures] = LogBook::Outdoor::Figure.new(@ascents).figures if @stats_list.include?('figures')
          stats[:climb_types_chart] = charts.climb_type if @stats_list.include?('climb_types_chart')
          stats[:grades_chart] = charts.grade if @stats_list.include?('grades_chart')
          stats[:years_chart] = charts.years if @stats_list.include?('years_chart')
          stats[:months_chart] = charts.months if @stats_list.include?('months_chart')
          stats[:evolution_chart] = charts.evolution_by_year if @stats_list.include?('evolution_chart')
          Rails.logger.info("stats: #{stats}")
          render json: stats, status: :ok
        end

        def ascended_crag_routes
          page = params.fetch(:page, 1)
          render json: LogBook::Outdoor::List.new(@ascents).ascended_crag_routes(page, params[:order]), status: :ok
        end

        def daily_ascents
          dates = []
          ascents_by_days = {}
          today = Date.current
          min_ascent_date = @user.ascent_crag_routes.made.minimum(:released_at)
          max_ascent_date = @user.ascent_crag_routes.made.maximum(:released_at)

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

            ascents = @user.ascent_crag_routes.made.where('DATE(released_at) IN(?)', dates).order(:released_at)
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
          if params[:user_id].present?
            @user = if /^[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}$/.match? params[:user_id].to_s
                      User.find_by uuid: params[:user_id]
                    else
                      User.find_by slug_name: params[:user_id]
                    end
          else
            @user = @current_user
          end
        end

        def set_ascents
          crag_filtered_ascents = LogBook::Outdoor::CragFilteredAscents.new(@user, params)
          @ascents = crag_filtered_ascents.ascents
        end

        def set_stats_list
          @stats_list = params.require(:stats_list)
        end
      end
    end
  end
end
