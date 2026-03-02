# frozen_string_literal: true

module Api
  module V1
    class FfmeContestsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session
      before_action :set_gym
      before_action :set_contest
      before_action :set_ffme_contest, only: %i[show update send_results link]
      before_action :protected_by_administrator
      before_action :user_can_manage_contest

      def show
        render json: @ffme_contest.detail_to_json, status: :ok
      end

      def create
        ffme_contest = FfmeContest.new ffme_contest_params
        ffme_contest.contest = @contest
        if ffme_contest.save
          ffme_contest.create_on_my_compet!
          render json: ffme_contest.detail_to_json, status: :ok
        else
          render json: { error: ffme_contest.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @ffme_contest.update(ffme_contest_params)
          @ffme_contest.update_on_my_compet!
          render json: @contest.detail_to_json, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def link
        render json: { link: @ffme_contest.link_on_my_compet['urlResultats'] }, status: :ok
      end

      def send_results
        if @ffme_contest.sendable?
          @ffme_contest.send_results!
          render json: @ffme_contest.detail_to_json, status: :ok
        else
          render json: { error: { base: ['ffme_contest_is_not_sendable'] } }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_ffme_contest
        @ffme_contest = FfmeContest.find_by(contest: @contest, id: params[:id])
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def ffme_contest_params
        params.require(:ffme_contest).permit(
          :name,
          :description,
          :start_date,
          :end_date,
          :contest_type,
          :contact_email,
          :contact_phone
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
