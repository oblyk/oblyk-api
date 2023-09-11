# frozen_string_literal: true

module Api
  module V1
    class ContestParticipantsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[index export create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_participant, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[export create update destroy]
      before_action :user_can_manage_contest, except: %i[index show participant subscribe]

      def index
        render json: @contest.contest_participants.includes(:contest_category, :contest_wave).map(&:summary_to_json), status: :ok
      end

      def export
        send_data @contest.contest_participants.to_csv, filename: "export-participant-#{@contest.name.parameterize}-#{Date.current}.csv"
      end

      def show
        data = @contest_participant.detail_to_json
        data[:steps] = @contest_participant.steps
        render json: data, status: :ok
      end

      def participant
        token = params[:id].sub(/(.*)-/, '\1.')
        participant = @contest.contest_participants.find_by token: token
        unless participant
          render json: 'no_found', status: :not_found
          return
        end

        render json: {
          token: participant.token,
          first_name: participant.first_name,
          last_name: participant.last_name,
          wave: participant.contest_wave&.name,
          category: participant.contest_category.name,
          steps: participant.steps
        }
      end

      def subscribe
        participant = ContestParticipant.new(contest_participant_params)
        participant.contest = @contest
        create_account = params[:contest_participant][:create_account] == true
        save_user = params[:contest_participant][:save_user] == true
        session_token = nil
        session_refresh_token = nil
        user = nil

        # Is user want create an account but email is not free
        if create_account && User.find_by(email: participant.email).exists?
          render json: { error: { base: ["le compte #{participant.email} existe déjà, connectez-vous pour vous inscrire"] }}, status: :unprocessable_entity
          return
        end

        # Create account
        if create_account
          user = User.new(
            first_name: contest_participant_params[:first_name],
            last_name: contest_participant_params[:last_name],
            date_of_birth: contest_participant_params[:date_of_birth],
            genre: contest_participant_params[:genre],
            email: contest_participant_params[:email],
            password: params[:contest_participant][:password],
            password_confirmation: params[:contest_participant][:password_confirmation]
          )
          if user.save
            user_data = user.as_json(only: %i[id first_name last_name])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            session_token = JwtToken::Token.generate(user_data, exp)
            session_refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)
          else
            render json: { error: user.errors }, status: :unprocessable_entity
            return
          end
        end

        # Save user in participant if new account or user is logged and want save contest
        participant.user = @current_user if save_user && login?
        participant.user = user if user && save_user

        if participant.save
          render json: {
            token: participant.token,
            session_token: session_token,
            session_refresh_token: session_refresh_token
          }, status: :created
        else
          render json: { error: participant.errors }, status: :unprocessable_entity
        end
      end

      def create
        @contest_participant = ContestParticipant.new(contest_participant_params)
        @contest_participant.contest = @contest
        if @contest_participant.save
          render json: @contest_participant.detail_to_json, status: :ok
        else
          render json: { error: @contest_participant.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @contest_participant.update(contest_participant_params)
          render json: @contest_participant.detail_to_json, status: :ok
        else
          render json: { error: @contest_participant.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @contest_participant.destroy
          render json: {}, status: :ok
        else
          render json: { error: @contest_participant.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_participant
        @contest_participant = @contest.contest_participants.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def contest_participant_params
        params.require(:contest_participant).permit(
          :first_name,
          :last_name,
          :date_of_birth,
          :genre,
          :email,
          :affiliation,
          :contest_category_id,
          :contest_wave_id
        )
      end

      def user_can_manage_contest
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
