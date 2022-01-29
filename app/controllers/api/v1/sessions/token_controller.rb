# frozen_string_literal: true

module Api
  module V1
    module Sessions
      class TokenController < ApiController
        def refresh
          refresh_token = JwtToken::Token.decode(params[:refresh_token]).try(:[], 'data')

          user_id = refresh_token.try(:[], 'id')
          render json: {}, status: :forbidden unless user_id

          user = User.find_by id: user_id
          render json: {}, status: :forbidden unless user

          user_data = user.as_json(only: %i[id first_name last_name slug_name email uuid super_admin])
          exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
          token = JwtToken::Token.generate(user_data, exp)
          new_refresh_token = JwtToken::Token.generate(user_data, exp + 3.months)

          user.activity!

          render json: {
            token: token,
            refresh_token: new_refresh_token
          }, status: :created
        end
      end
    end
  end
end
