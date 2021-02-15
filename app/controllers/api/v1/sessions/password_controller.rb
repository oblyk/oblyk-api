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

            user.reset_password_token = nil
            user.reset_password_token_expired_at = nil
            user.save

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

            render json: {
              auth: true,
              user: user_data,
              token: token,
              expired_at: exp,
              refresh_token: refresh_token,
              administered_gyms: user.gyms.map(&:id),
              subscribes: user.subscribes_to_a,
              ascent_crag_routes: user.ascent_crag_routes_to_a,
              tick_list: user.tick_list_to_a
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
