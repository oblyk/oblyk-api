# frozen_string_literal: true

module Api
  module V1
    class ChampionshipContestsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session
      before_action :set_gym
      before_action :set_championship
      before_action :protected_by_administrator
      before_action :user_can_manage_championship

      def create
        contest_id = params[:championship][:contest_id]
        ChampionshipContest.find_or_create_by contest_id: contest_id, championship: @championship
        head :no_content
      end

      def delete
        contest_id = params[:championship][:contest_id]
        contest = @championship.championship_contests.find_by contest_id: contest_id
        contest&.destroy
        head :no_content
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_championship
        @championship = @gym.all_championships.find(params[:championship_id])
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def user_can_manage_championship
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
