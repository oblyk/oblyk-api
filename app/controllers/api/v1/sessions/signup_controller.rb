# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class SignupController < ApiController
        def create
          user = User.new(user_params)
          if user.save
            user_data = user.as_json(only: %i[id first_name last_name slug_name email uuid super_admin])
            exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
            token = JwtToken::Token.generate(user_data, exp)

            http_user_agent = UserAgent.parse(request.user_agent)
            user_agent = "#{http_user_agent.platform || 'platform'}, #{http_user_agent.browser || 'browser'}"
            refresh_token = RefreshToken.find_or_initialize_by user_agent: user_agent, user: user
            refresh_token.unused_token
            refresh_token.save

            if params.fetch(:newsletter_subscribe, false)
              already_subscribe = Subscribe.find_by email: user.email
              Subscribe.create(email: user.email) unless already_subscribe
            end

            UserMailer.with(user: user).welcome.deliver_later

            render json: {
              auth: true,
              user: user_data,
              token: token,
              expired_at: exp,
              refresh_token: refresh_token.token,
              ws_token: user.ws_token,
              administered_gyms: user.administered_gyms.map(&:id),
              subscribes: user.subscribes_to_a,
              ascent_crag_routes: user.ascent_crag_routes_to_a,
              ascent_gym_routes: user.ascent_gym_routes_to_a,
              tick_list: user.tick_list_to_a
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
            :description
          )
        end
      end
    end
  end
end

