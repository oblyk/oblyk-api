# frozen_string_literal: true

module Api
  module V1
    class ContestStagesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_stage, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[create update destroy]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        render json: @contest.contest_stages.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_stage.detail_to_json, status: :ok
      end

      def create
        @contest_stage = ContestStage.new(contest_stage_params)
        @contest_stage.contest = @contest
        if @contest_stage.save
          render json: @contest_stage.detail_to_json, status: :ok
        else
          render json: { error: @contest_stage.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_stage.update(contest_stage_params)
          render json: @contest_stage.detail_to_json, status: :ok
        else
          render json: { error: @contest_stage.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_stage.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_stage.errors }, status: :unprocessable_entity
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
        @contest_stage = @contest.contest_stages.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_stage_params
        params.require(:contest_stage).permit(
          :climbing_type,
          :name,
          :description,
          :stage_order,
          :default_ranking_type
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
