# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SigninController < ApiController
        def create
          user = User.find_by email: params[:email]
          not_found && return if user.blank?

          if user.authenticate(params[:password])
            user_data = user.as_json(only: %i[id first_name last_name slug_name email uuid super_admin])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)
            refresh_token = nil

            if params.fetch(:remember_me, false)
              http_user_agent = UserAgent.parse(request.user_agent)
              user_agent = "#{http_user_agent.platform || 'platform'}, #{http_user_agent.browser || 'browser'}"
              refresh_token = RefreshToken.find_or_initialize_by user_agent: user_agent, user: user
              refresh_token.unused_token
              refresh_token.save
            end

            user.activity!

            render json: {
              auth: true,
              user: user_data,
              token: token,
              expired_at: exp,
              refresh_token: refresh_token&.token,
              administered_gyms: user.gyms.map(&:id),
              subscribes: user.subscribes_to_a,
              ascent_crag_routes: user.ascent_crag_routes_to_a,
              tick_list: user.tick_list_to_a
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
