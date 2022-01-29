# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SigninController < ApiController
        def create
          user = User.find_by email: params[:email]
          not_found && return if user.blank?

          if user.authenticate(params[:password])
            user_data = user.as_json(only: %i[id first_name last_name])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)

            refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)

            user.activity!

            render json: {
              token: token,
              refresh_token: refresh_token
            }, status: :created
          else
            not_found
          end
        end

        def destroy
          head :no_content
        end

        private

        def not_found
          render json: { error: { base: ['email_or_password_suite_not_find'] } }, status: :unprocessable_entity
        end
      end
    end
  end
end
