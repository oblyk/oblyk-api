# frozen_string_literal: true

module Api
  module V1
    class ChampionshipsController < ApiController
      include UploadVerification
      include GymRolesVerification
      include ImageParamsConvert

      before_action :protected_by_session, only: %i[available_contests create update destroy add_banner archived unarchived]
      before_action :set_gym
      before_action :set_championship, only: %i[available_contests show update destroy add_banner archived unarchived results contests]
      before_action :protected_by_administrator, only: %i[available_contests create update destroy archived unarchived add_banner]
      before_action :user_can_manage_championship, except: %i[index show results contests]

      def index
        championships = @gym.all_championships.order(:archived_at, created_at: :desc)
        render json: championships.map(&:summary_to_json), status: :ok
      end

      def available_contests
        gyms = []
        @gym.gym_chains.each do |gym_chain|
          gyms.concat(gym_chain.gyms.pluck(:id))
        end
        gyms = Gym.where(id: gyms).includes(:contests).order(:name)
        championship_contest_ids = @championship.contests.pluck(:id)
        contests = []
        gyms.each do |gym|
          gym.contests.order(start_date: :desc).each do |contest|
            next if championship_contest_ids.include? contest.id

            contests << contest.summary_to_json
          end
        end
        render json: contests, status: :ok
      end

      def show
        render json: @championship.detail_to_json, status: :ok
      end

      def results
        if @championship.results
          render json: @championship.results, status: :ok
        else
          head :no_content
        end
      end

      def contests
        render json: @championship.contests.order(:start_date).map(&:summary_to_json), status: :ok
      end

      def create
        @championship = Championship.new(championship_params)
        @championship.gym = @gym
        if @championship.save
          render json: @championship.detail_to_json, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @championship.update(championship_params)
          render json: @championship.detail_to_json, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @championship.destroy
          render json: {}, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        return unless verify_file banner_params[:banner], :image

        params[:championship][:banner] = convert_image_on_params %i[championship banner]
        if @championship.update(banner_params)
          render json: @championship.detail_to_json, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      def archived
        if @championship.archive!
          render json: {}, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      def unarchived
        if @championship.unarchive!
          render json: {}, status: :ok
        else
          render json: { error: @championship.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_championship
        @championship = @gym.all_championships.find(params[:id])
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def championship_params
        params.require(:championship).permit(
          :name,
          :description,
          :combined_ranking_type
        )
      end

      def banner_params
        params.require(:championship).permit(
          :banner
        )
      end

      def user_can_manage_championship
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
