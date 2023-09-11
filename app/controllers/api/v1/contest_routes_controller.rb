# frozen_string_literal: true

module Api
  module V1
    class ContestRoutesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, except: %i[index show]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_route, only: %i[show update destroy disable enable linked unlinked]
      before_action :protected_by_administrator, only: %i[create update destroy disable enable linked unlinked]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        render json: @contest.contest_routes.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_route.detail_to_json, status: :ok
      end

      def create
        @contest_route = ContestRoute.new(contest_route_params)
        @contest_route.contest = @contest
        if @contest_route.save
          render json: @contest_route.detail_to_json, status: :ok
        else
          render json: { error: @contest_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_route.update(contest_route_params)
          render json: @contest_route.detail_to_json, status: :ok
        else
          render json: { error: @contest_route.errors }, status: :unprocessable_entity
        end
      end

      def linked
        if @contest_route.update(contest_route_link_params)
          head :no_content
        else
          render json: { error: @contest_route.errors }, status: :unprocessable_entity
        end
      end

      def unlinked
        @contest_route.gym_route_id = nil
        @contest_route.save
        head :no_content
      end

      def disable
        @contest_route.disable!
        head :no_content
      end

      def enable
        @contest_route.enable!
        head :no_content
      end

      def destroy
        if @contest_route.contest_participant_ascents.count.positive?
          render json: { error: { base: ['La ligne a des réalisations, elle ne peut pas être supprimée'] } }, status: :unprocessable_entity
          return
        end

        if @contest_route.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_route.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_route
        @contest_route = @contest.contest_routes.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_mass_route_params
        params.require(:contest_route).permit(
          :number_to_create
        )
      end

      def contest_route_params
        params.require(:contest_route).permit(
          :number
        )
      end

      def contest_route_link_params
        params.require(:contest_route).permit(
          :gym_route_id
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
