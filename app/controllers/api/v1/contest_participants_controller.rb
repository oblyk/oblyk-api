# frozen_string_literal: true

module Api
  module V1
    class ContestParticipantsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[index export import import_template create update destroy]
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_participant, only: %i[show update destroy]
      before_action :protected_by_administrator, only: %i[export import import_template create update destroy]
      before_action :user_can_manage_contest, except: %i[index show participant subscribe]

      def index
        render json: @contest.contest_participants.includes(:contest_category, :contest_wave).map(&:summary_to_json), status: :ok
      end

      def export
        send_data @contest.contest_participants.to_csv, filename: "export-participant-#{@contest.name.parameterize}-#{Date.current}.csv"
      end

      def import
        first_row = true
        errors = []
        file_row_count = 0
        created_count = 0
        already_imported_count = 0

        send_email = params[:contest_participant][:send_email] === 'true'

        CSV.foreach(params[:contest_participant][:file].path, col_sep: ';') do |row|
          if first_row
            first_row = false
            next
          end
          file_row_count += 1

          first_name = row[0]&.strip
          last_name = row[1]&.strip
          date_of_birth = row[2]&.strip || ''
          if date_of_birth.match /^\d{1,2}\s[a-zéû]+\s\d{4}$/
            dates = date_of_birth.split ' '
            months = %w[janvier février mars avril mai juin juillet août septembre octobre novembre decembre]
            month = months.find_index(dates[1]) + 1
            date_of_birth = Date.new(dates[2].to_i, month, dates[0].to_i)
          elsif date_of_birth.match(/^\d{2,4}-\d{2}-\d{2,4}$/)
            date_of_birth = Date.parse(date_of_birth)
          else
            date_of_birth = nil
          end
          email = row[3]&.strip
          genre = row[4]&.strip
          genre = 'male' if genre == 'homme'
          genre = 'female' if genre == 'femme'
          category_name = row[5]&.strip
          wave_name = row[6]&.strip

          if date_of_birth.blank?
            errors << "#{first_name} #{last_name} doit avoir une date de naissance"
            next
          end

          if first_name.blank? || last_name.blank?
            errors << "#{email} doit avoir un nom est un prénom"
            next
          end

          unless date_of_birth
            errors << "#{first_name} #{last_name} doit avoir une date de naissance"
            next
          end

          unless genre
            errors << "#{first_name} #{last_name} doit avoir un genre : homme ou femme"
            next
          end

          unless email
            errors << "#{first_name} #{last_name} doit avoir un email"
            next
          end

          category = @contest.contest_categories.find_by name: category_name

          unless category
            errors << "#{first_name} #{last_name} doit être inscrit(e) dans l'une des catégories suivantes : #{@contest.contest_categories.pluck(:name).join(', ')}"
            next
          end

          wave = nil
          if category.waveable
            wave = @contest.contest_waves.find_by name: wave_name
            unless wave
              errors << "#{first_name} #{last_name} doit être inscrit(e) dans l'une des vagues suivantes : #{@contest.contest_waves.pluck(:name).join(', ')}"
              next
            end
          end

          if @contest.contest_participants.exists?(first_name: first_name, last_name: last_name, date_of_birth: date_of_birth)
            already_imported_count += 1
            next
          end

          user = User.find_by email: email

          participant = @contest.contest_participants.new(
            first_name: first_name,
            last_name: last_name,
            date_of_birth: date_of_birth,
            genre: genre,
            email: email,
            contest_category: category,
            user: user
          )
          participant.skip_subscription_mail = true unless send_email
          participant.contest_wave = wave if wave
          if participant.save
            created_count += 1
          else
            errors << participant.errors.full_messages
          end
        end

        render json: {
          file_row_count: file_row_count,
          created_count: created_count,
          already_imported_count: already_imported_count,
          errors_count: errors.count,
          errors: errors
        }, status: :ok
      end

      def import_template
        header = CSV.generate(headers: true, encoding: 'utf-8', col_sep: ";") do |csv|
          head = [
            'Prénom',
            'Nom de famille',
            'Date de naissance',
            'Email',
            'Genre (homme, femme)'
          ]
          head << "Catégorie (#{@contest.contest_categories.pluck(:name).join(', ')})"
          if @contest.contest_waves.count > 0
            head << "Vague (#{@contest.contest_waves.pluck(:name).join(', ')})"
          end
          csv << head
        end
        send_data header, filename: "template-import-participant-#{@contest.slug_name}.csv"
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
        if create_account && User.exists?(email: participant.email)
          render json: { error: { base: ["le compte #{participant.email} existe déjà, connectez-vous pour vous inscrire"] } }, status: :unprocessable_entity
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
            UserMailer.with(user: user).welcome.deliver_later
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
