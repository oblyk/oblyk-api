# frozen_string_literal: true

module Api
  module V1
    class ContestStageStepsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_stage
      before_action :set_contest_stage_step, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[create update destroy]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        steps = @contest_stage.contest_stage_steps.map do |step|
          step.summary_to_json(with_routes: params[:with_routes] == 'true')
        end
        render json: steps, status: :ok
      end

      def show
        render json: @contest_stage_step.detail_to_json, status: :ok
      end

      def create
        @contest_stage_step = ContestStageStep.new(contest_stage_step_params)
        @contest_stage_step.contest_stage = @contest_stage
        if @contest_stage_step.save
          render json: @contest_stage_step.detail_to_json, status: :ok
        else
          render json: { error: @contest_stage_step.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_stage_step.update(contest_stage_step_params)
          render json: @contest_stage_step.detail_to_json, status: :ok
        else
          render json: { error: @contest_stage_step.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_stage_step.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_stage_step.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_stage
        @contest_stage = @contest.contest_stages.find params[:contest_stage_id]
      end

      def set_contest_stage_step
        @contest_stage_step = @contest_stage.contest_stage_steps.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_stage_step_params
        params.require(:contest_stage_step).permit(
          :name,
          :step_order,
          :ranking_type,
          :self_reporting,
          :default_participants_for_next_step
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
