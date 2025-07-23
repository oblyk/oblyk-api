# frozen_string_literal: true

module Api
  module V1
    class ContestJudgesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_judge, only: %i[show update destroy add_routes delete_route]
      before_action :protected_by_administrator
      before_action :user_can_manage_contest

      def index
        render json: @contest.contest_judges.order(:name).map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_judge.detail_to_json, status: :ok
      end

      def create
        @contest_judge = ContestJudge.new(contest_judge_params)
        @contest_judge.contest = @contest
        if @contest_judge.save
          render json: @contest_judge.detail_to_json, status: :ok
        else
          render json: { error: @contest_judge.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_judge.update(contest_judge_params)
          render json: @contest_judge.detail_to_json, status: :ok
        else
          render json: { error: @contest_judge.errors }, status: :unprocessable_entity
        end
      end

      def add_routes
        routes = @contest.contest_routes
                         .where(id: params[:contest_judge][:contest_route_ids])
                         .where.not(id: @contest_judge.contest_routes.pluck(:id))
        routes.each do |route|
          @contest_judge.contest_routes << route
        end
        head :no_content
      end

      def delete_route
        routes = @contest_judge.contest_judge_routes.where(contest_route_id: params[:contest_route_id])
        routes.each(&:destroy)
        head :no_content
      end

      def destroy
        if @contest_judge.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_judge.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_judge
        @contest_judge = @contest.contest_judges.includes(contest_judge_routes: :contest_route).find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_judge_params
        params.require(:contest_judge).permit(
          :name,
          :code,
          contest_route_ids: []
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
