# frozen_string_literal: true

module AuthHelper
  def generate_token(user)
    user_data = user.as_json(only: %i[id first_name last_name])
    exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
    JwtToken::Token.generate(user_data, exp)
  end

  def api_headers(user: :normal_user, organization: :oblyk_orga)
    {
      'Authorization' => generate_token(users(user)),
      'HttpApiAccessToken' => organizations(organization).api_access_token,
      'Content-Type' => 'application/json'
    }
  end

  def api_access_token_headers(organization: :oblyk_orga)
    {
      'HttpApiAccessToken' => organizations(organization).api_access_token,
      'Content-Type' => 'application/json'
    }
  end
end
