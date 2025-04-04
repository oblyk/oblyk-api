# frozen_string_literal: true

module Api
  module V1
    class ContestWavesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_wave, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[create update destroy]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        render json: @contest.contest_waves.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_wave.detail_to_json, status: :ok
      end

      def create
        @contest_wave = ContestWave.new(contest_wave_params)
        @contest_wave.contest = @contest
        if @contest_wave.save
          render json: @contest_wave.detail_to_json, status: :ok
        else
          render json: { error: @contest_wave.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_wave.update(contest_wave_params)
          render json: @contest_wave.detail_to_json, status: :ok
        else
          render json: { error: @contest_wave.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_wave.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_wave.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_wave
        @contest_wave = @contest.contest_waves.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_wave_params
        params.require(:contest_wave).permit(
          :name,
          :capacity
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
