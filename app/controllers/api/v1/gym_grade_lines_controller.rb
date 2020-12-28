# frozen_string_literal: true

module Api
  module V1
    class GymGradeLinesController < ApiController
      include Gymable
      before_action :set_gym_grade
      before_action :set_gym_grade_line, only: %i[show update destroy]

      def show; end

      def create
        @gym_grade_line = GymGradeLine.new(gym_grade_line_params)
        @gym_grade_line.gym_grade = @gym_grade
        if @gym_grade_line.save
          render 'api/v1/gym_grade_lines/show'
        else
          render json: { error: @gym_grade_line.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_grade_line.update(gym_grade_line_params)
          render 'api/v1/gym_grade_lines/show'
        else
          render json: { error: @gym_grade_line.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_grade_line.delete
          render 'api/v1/gym_grades/show'
        else
          render json: { error: @gym_grade_line.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_grade
        @gym_grade = GymGrade.find params[:gym_grade_id]
      end

      def set_gym_grade_line
        @gym_grade_line = GymGradeLine.find params[:id]
      end

      def gym_grade_line_params
        params.require(:gym_grade_line).permit(
          :name,
          :order,
          :grade_text,
          :points,
          colors: []
        )
      end
    end
  end
end
