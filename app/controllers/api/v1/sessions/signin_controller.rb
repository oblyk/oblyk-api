# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SigninController < ApiController
        def create
          user = User.find_by email: params[:email]
          not_found && return if user.blank?

          if user.authenticate(params[:password])
            user_data = user.as_json(only: %i[id first_name last_name email])
            token = JwtToken::Token.generate(user_data)

            render json: {
              auth: true,
              user: user_data,
              token: token
            }, status: :created
          else
            not_found
          end
        end

        private

        def not_found
          render json: { error: 'Cannot find email/password combination' }, status: :not_found
        end
      end
    end
  end
end
