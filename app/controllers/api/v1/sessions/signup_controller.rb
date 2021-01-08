# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SignupController < ApiController
        def create
          user = User.new(user_params)
          if user.save
            user_data = user.as_json(only: %i[id first_name last_name slug_name email])
            exp = Time.now.to_i + 24 * 3600
            token = JwtToken::Token.generate(user_data, exp)
            refresh_token = nil

            if params.fetch(:remember_me, false)
              http_user_agent = UserAgent.parse(request.user_agent)
              user_agent = "#{http_user_agent.platform || 'platform'}, #{http_user_agent.browser || 'browser'}"
              refresh_token = RefreshToken.find_or_initialize_by user_agent: user_agent, user: user
              refresh_token.unused_token
              refresh_token.save
            end

            UserMailer.with(user: user).welcome.deliver_later

            render json: {
              auth: true,
              user: user_data,
              token: token,
              expired_at: exp,
              refresh_token: refresh_token,
              administered_gyms: user.gyms.map(&:id)
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
            :last_name,
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

