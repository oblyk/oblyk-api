# frozen_string_literal: true

module Api
  module V1
    class ContestRouteGroupsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_stage
      before_action :set_contest_stage_step
      before_action :set_contest_route_group, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[create update destroy]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        steps = @contest_stage_step.contest_route_groups.map(&:summary_to_json)
        render json: steps, status: :ok
      end

      def show
        render json: @contest_route_group.detail_to_json, status: :ok
      end

      def create
        @contest_route_group = ContestRouteGroup.new(contest_route_group_params)
        @contest_route_group.contest_stage_step = @contest_stage_step
        if @contest_route_group.save
          number_of_routes = params[:contest_route_group][:number_of_routes]&.to_i
          if number_of_routes.present? && number_of_routes.positive?
            number_of_routes.times do |index|
              @contest_route_group.contest_routes << ContestRoute.new(number: index + 1)
            end
          end
          render json: @contest_route_group.detail_to_json, status: :ok
        else
          render json: { error: @contest_route_group.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_route_group.update(contest_route_group_params)
          render json: @contest_route_group.detail_to_json, status: :ok
        else
          render json: { error: @contest_route_group.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_route_group.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_route_group.errors }, status: :unprocessable_entity
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
        @contest_stage_step = @contest_stage.contest_stage_steps.find params[:contest_stage_step_id]
      end

      def set_contest_route_group
        @contest_route_group = @contest_stage_step.contest_route_groups.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_route_group_params
        params[:contest_route_group][:contest_time_blocks_attributes] = [] unless params[:contest_route_group][:waveable]
        params.require(:contest_route_group).permit(
          :waveable,
          :route_group_date,
          :start_time,
          :end_time,
          :start_date,
          :end_date,
          :additional_time,
          :genre_type,
          :number_participants_for_next_step,
          contest_category_ids: [],
          contest_time_blocks_attributes: %i[id start_time end_time start_date end_date additional_time contest_wave_id]
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
