# frozen_string_literal: true

module Api
  module V1
    class GradesController < ApiController
      def grade
        query_grade = grade_params[:grade]
        render json: {
          grade: query_grade,
          value: Grade.to_value(query_grade),
          color: Grade.grade_color(query_grade)
        }, status: :ok
      end

      def types
        render json: Grade::GRADE_STYLES, status: :ok
      end

      private

      def grade_params
        params.permit :grade
      end
    end
  end
end
