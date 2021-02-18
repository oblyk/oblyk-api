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

        private

        def set_user
          @user = @current_user
        end
      end
    end
  end
end
