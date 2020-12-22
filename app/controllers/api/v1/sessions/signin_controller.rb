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

            render json: {
              auth: true,
              user: user_data,
              token: token,
              expired_at: exp,
              refresh_token: refresh_token&.token
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
