# frozen_string_literal: true

module Api
  module V1
    class GymGradesController < ApiController
      include Gymable
      before_action :set_gym_grade, only: %i[show update destroy]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show]

      def index
        gym_grades = @gym.gym_grades
        render json: gym_grades.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_grade.detail_to_json, status: :ok
      end

      def create
        @gym_grade = GymGrade.new(gym_grade_params)
        @gym_grade.gym = @gym
        if @gym_grade.save
          render json: @gym_grade.detail_to_json, status: :ok
        else
          render json: { error: @gym_grade.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_grade.update(gym_grade_params)
          render json: @gym_grade.detail_to_json, status: :ok
        else
          render json: { error: @gym_grade.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_grade.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_grade.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_grade
        @gym_grade = GymGrade.find params[:id]
      end

      def gym_grade_params
        params.require(:gym_grade).permit(
          :name,
          :difficulty_by_grade,
          :difficulty_by_level,
          :tag_color,
          :hold_color,
          :point_system_type
        )
      end
    end
  end
end
