# frozen_string_literal: true

module Api
  module V1
    class ContestCategoriesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_category, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[create update destroy]
      before_action :user_can_manage_contest, except: %i[index show]

      def index
        render json: @contest.contest_categories.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest_category.detail_to_json, status: :ok
      end

      def create
        @contest_category = ContestCategory.new(contest_category_params)
        @contest_category.contest = @contest
        if @contest_category.save
          render json: @contest_category.detail_to_json, status: :ok
        else
          render json: { error: @contest_category.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_category.update(contest_category_params)
          render json: @contest_category.detail_to_json, status: :ok
        else
          render json: { error: @contest_category.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_category.contest_participants.count.positive?
          render json: { error: { base: ['La categorie a des participants, elle ne peut pas être supprimée'] } }, status: :unprocessable_entity
          return
        end

        if @contest_category.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_category.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_category
        @contest_category = @contest.contest_categories.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_category_params
        params.require(:contest_category).permit(
          :name,
          :description,
          :order,
          :capacity,
          :unisex,
          :auto_distribute,
          :registration_obligation,
          :min_age,
          :max_age,
          :waveable,
          :parity
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
