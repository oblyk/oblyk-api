# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class PasswordController < ApiController
        def create
          user = User.find_by email: params[:email]
          not_found && return if user.blank?

          user.send_reset_password_instructions
          render json: {}, status: :ok
        end

        def update
          user = User.find_by reset_password_token: params[:token]
          not_found && return if user.blank?

          token_is_expired && return if user.reset_password_token_expired_at < Time.zone.now

          user.password = params[:password]
          user.password_confirmation = params[:password_confirmation]

          if user.save
            user.update_column :reset_password_token, nil
            user.update_column :reset_password_token_expired_at, nil

            user_data = user.as_json(only: %i[id first_name last_name])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)
            refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)

            render json: {
              email: user.email,
              token: token,
              refresh_token: refresh_token
            }, status: :created
          else
            render json: { error: user.errors }, status: :unprocessable_entity
          end
        end

        private

        def not_found
          render json: { error: 'Cannot find email associated with account' }, status: :not_found
        end

        def token_is_expired
          render json: { error: 'Reset password token is expired' }, status: :unprocessable_entity
        end
      end
    end
  end
end
