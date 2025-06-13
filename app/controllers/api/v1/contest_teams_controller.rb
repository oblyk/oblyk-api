# frozen_string_literal: true

module Api
  module V1
    class ContestTeamsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_team, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[update destroy]
      before_action :user_can_manage_contest, except: %i[create index show]

      def index
        render json: @contest.contest_teams.includes(:contest_participants, :contest).order(:name).map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_team.detail_to_json, status: :ok
      end

      def create
        @contest_team = ContestTeam.new(contest_team_params)
        @contest_team.contest = @contest
        if @contest_team.save
          render json: @contest_team.detail_to_json, status: :ok
        else
          render json: { error: @contest_team.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_team.update(contest_team_params)
          render json: @contest_team.detail_to_json, status: :ok
        else
          render json: { error: @contest_team.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_team.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_team.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_team
        @contest_team = @contest.contest_teams.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_team_params
        params.require(:contest_team).permit(
          :name
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
