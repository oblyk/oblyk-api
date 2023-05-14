# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SignupController < ApiController
        def create
          user = User.new(user_params)
          if user.save
            user_data = user.as_json(only: %i[id first_name last_name])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)
            refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)

            if params.fetch(:newsletter_subscribe, false)
              already_subscribe = Subscribe.find_by email: user.email
              Subscribe.create(email: user.email) unless already_subscribe
            end

            UserMailer.with(user: user).welcome.deliver_later

            render json: {
              token: token,
              refresh_token: refresh_token
            }, status: :created
          else
            render json: { error: user.errors }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.permit(
            :email,
            :first_name,
            :last_name,
            :password,
            :password_confirmation,
            :date_of_birth,
            :genre,
            :description,
            :public_profile,
            :public_outdoor_ascents,
            :public_indoor_ascents
          )
        end
      end
    end
  end
end

