# frozen_string_literal: true

module Api
  module V1
    class ChampionshipCategoriesController < ApiController
      include GymRolesVerification

      before_action :protected_by_session
      before_action :set_gym
      before_action :set_championship
      before_action :set_championship_category, only: %i[show destroy]
      before_action :protected_by_administrator
      before_action :user_can_manage_championship

      def index
        render json: @championship.championship_categories.all.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @championship_category.summary_to_json, status: :ok
      end

      def contest_categories
        contests = []
        championship_category_ids = @championship.championship_category_matches.pluck(:contest_category_id)
        @championship.contests.each do |contest|
          categories = []
          contest.contest_categories.map do |contest_category|
            categories << {
              id: contest_category.id,
              name: contest_category.name,
              already_taken: championship_category_ids.include?(contest_category.id)
            }
          end
          data = {
            id: contest.id,
            name: contest.name,
            attachments: {
              banner: contest.banner_attachment_object
            },
            gym: {
              id: contest.gym.id,
              name: contest.gym.name,
              slug_name: contest.gym.slug_name
            },
            contest_categories: categories
          }
          contests << data
        end
        render json: contests, status: :ok
      end

      def create
        name = params[:championship_category][:name]
        categories = params[:championship_category][:contest_categories]
        championship_category = ChampionshipCategory.new name: name, championship: @championship
        categories.each do |contest_category|
          championship_category.championship_category_matches << ChampionshipCategoryMatch.new(contest_category_id: contest_category)
        end
        championship_category.save
        head :no_content
      end

      def destroy
        @championship_category.destroy
        head :no_content
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_championship
        @championship = @gym.all_championships.find(params[:championship_id])
      end

      def set_championship_category
        @championship_category = @championship.championship_categories.find(params[:id])
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
