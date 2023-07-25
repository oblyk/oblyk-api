# frozen_string_literal: true

module Api
  module V1
    module Statistics
      class GymRouteStatisticsController < ApiController
        include Gymable

        before_action :set_statistic_module

        def figures
          render json: @stat.figures, status: :ok
        end

        def routes_by_grades
          render json: @stat.routes_by_grades, status: :ok
        end

        def routes_by_levels
          render json: @stat.routes_by_levels, status: :ok
        end

        def notes
          render json: @stat.notes, status: :ok
        end

        def like_figures
          render json: @stat.like_figures, status: :ok
        end

        def difficulty_figures
          render json: @stat.difficulty_appreciation, status: :ok
        end

        def appreciation_figures
          render json: {
            like: @stat.like_figures,
            difficulty: @stat.difficulty_appreciation
          }, status: :ok
        end

        def opening_frequencies
          render json: @stat.opening_frequencies, status: :ok
        end

        private

        def filter_params
          params.require(:filters).permit(
            :date,
            space_ids: [],
            opener_ids: []
          )
        end

        def set_statistic_module
          @stat = ::Statistics::GymStatistic.new(
            @gym,
            Date.parse(filter_params[:date]),
            space_ids: filter_params[:space_ids],
            opener_ids: filter_params[:opener_ids]
          )
        end

      end
    end
  end
end
