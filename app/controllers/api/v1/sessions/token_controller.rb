# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class TokenController < ApiController
        def refresh
          user = User.find_by uuid: params[:uuid]
          http_user_agent = UserAgent.parse(request.user_agent)
          user_agent = "#{http_user_agent.platform || 'platform'}, #{http_user_agent.browser || 'browser'}"
          refresh_token = RefreshToken.find_by user_agent: user_agent, user: user

          if refresh_token.present?
            user_data = user.as_json(only: %i[id first_name last_name slug_name email uuid])
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
