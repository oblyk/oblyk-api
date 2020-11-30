# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SignupController < ApiController
        def create
          user = User.new(user_params)
          if user.save
            user_data = user.as_json(only: %i[id first_name first_name email])
            token = JwtToken::Token.generate(user_data)

            render json: {
              auth: true,
              user: user_data,
              token: token
            }, status: :created
          else
            render json: { error: user.errors.full_messages.join(' ') }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.permit(
            :email,
            :first_name,
            :password,
            :password_confirmation,
            :date_of_birth,
            :genre,
            :description
          )
        end
      end
    end
  end
end

