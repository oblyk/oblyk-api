# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class TokenController < ApiController
        def refresh
          # user = User.find_by RefreshToken: params[:refresh_token]
          http_user_agent = UserAgent.parse(request.user_agent)
          user_agent = "#{http_user_agent.platform || 'platform'}, #{http_user_agent.browser || 'browser'}"
          refresh_token = RefreshToken.find_by token: params[:refresh_token], user_agent: user_agent

          if refresh_token.present?
            user = refresh_token.user
            user_data = user.as_json(only: %i[id first_name last_name slug_name email uuid super_admin])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)
            refresh_token.unused_token
            refresh_token.save

            user.activity!

            render json: {
              token: token,
              expired_at: exp,
              refresh_token: refresh_token.token
            }, status: :created
          else
            render json: {}, status: :unauthorized
          end
        end
      end
    end
  end
end
