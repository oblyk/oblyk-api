# frozen_string_literal: true

module Api
  module V1
    class ContestParticipantStepsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_participant
      before_action :set_contest_stage_step
      before_action :protected_by_administrator
      before_action :user_can_manage_contest

      def subscribe
        subscribe = params[:contest_participant_step][:subscribe]
        if subscribe
          ContestParticipantStep.find_or_create_by(
            contest_participant: @contest_participant,
            contest_stage_step: @contest_stage_step
          )
        else
          participant_step = ContestParticipantStep.find_by(
            contest_participant: @contest_participant,
            contest_stage_step: @contest_stage_step
          )
          participant_step&.destroy
        end
        head :no_content
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_participant
        @contest_participant = @contest.contest_participants.find params[:contest_participant_step][:contest_participant_id]
      end

      def set_contest_stage_step
        @contest_stage_step = @contest.contest_stage_steps.find params[:contest_participant_step][:contest_stage_step_id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
