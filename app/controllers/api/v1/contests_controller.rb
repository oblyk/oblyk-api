# frozen_string_literal: true

module Api
  module V1
    class ContestsController < ApiController
      include UploadVerification
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create update destroy add_banner draft archived unarchived time_line export_results statistics]
      before_action :set_gym, except: %i[opens]
      before_action :set_contest, only: %i[show update destroy draft archived unarchived add_banner time_line results export_results statistics]
      before_action :protected_by_administrator, only: %i[create update destroy draft archived unarchived add_banner time_line export_results statistics]
      before_action :user_can_manage_contest, except: %i[opens index show results]

      def opens
        contests = Contest.where(draft: false, private: false).order(start_date: :desc)
        contest_by_dates = {
          is_coming: [],
          ongoing: [],
          past: []
        }
        contests.each do |contest|
          if contest.finished?
            contest_by_dates[:past] << contest.summary_to_json
          elsif contest.coming?
            contest_by_dates[:is_coming] << contest.summary_to_json
          elsif contest.ongoing?
            contest_by_dates[:ongoing] << contest.summary_to_json
          end
        end

        render json: contest_by_dates, status: :ok
      end

      def index
        render json: @gym.contests.order(:archived_at, start_date: :desc).map(&:summary_to_json), status: :ok
      end

      def show
        render json: @contest.detail_to_json, status: :ok
      end

      def time_line
        render json: @contest.time_line, status: :ok
      end

      def results
        by_team = params.fetch(:by_team, 'false') == 'true'
        by_team = false unless @contest.team_contest
        unisex = params.fetch(:unisex, 'false') == 'true'
        render json: ContestService::Result.new(@contest, by_team: by_team, unisex: unisex).results, status: :ok
      end

      def export_results
        send_data @contest.results_to_csv, filename: "export-results-#{@contest.name&.parameterize}-#{Date.current}.csv"
      end

      def statistics
        statistics = ContestService::Statistics.new(
          @contest,
          category_id: params[:category_id],
          genre: params[:genre],
          exclude_without_ascents: params.fetch(:exclude_without_ascents, 'false') == 'true'
        )
        render json: {
          participants: {
            figures: statistics.participants_figure,
            by_ages: statistics.by_ages
          },
          ascents: {
            by_steps: statistics.ascents_by_steps
          }
        }, status: :ok
      end

      def create
        @contest = Contest.new(contest_params)
        @contest.gym = @gym
        if @contest.save
          render json: @contest.detail_to_json, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest.update(contest_params)
          render json: @contest.detail_to_json, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        return unless verify_file banner_params[:banner], :image

        if @contest.update(banner_params)
          render json: @contest.detail_to_json, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        unless @contest.draft?
          render json: { error: { base: ['published_contest_cannot_be_deleted'] }}, status: :unprocessable_entity
          return
        end

        if @contest.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def draft
        @contest.draft = params[:contest][:draft]
        @contest.save
      end

      def archived
        if @contest.archive!
          render json: {}, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      def unarchived
        if @contest.unarchive!
          render json: {}, status: :ok
        else
          render json: { error: @contest.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_params
        params.require(:contest).permit(
          :name,
          :description,
          :start_date,
          :end_date,
          :subscription_start_date,
          :subscription_end_date,
          :total_capacity,
          :categorization_type,
          :authorise_public_subscription,
          :combined_ranking_type,
          :private,
          :hide_results,
          :team_contest,
          :participant_per_team
        )
      end

      def banner_params
        params.require(:contest).permit(
          :banner
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
