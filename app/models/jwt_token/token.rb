# frozen_string_literal: true

module JwtToken
  class Token
    # By default, the token is valid for 24 hours
    def self.generate(data, exp = Time.now.to_i + (24 * 3600))
      JWT.encode({ data: data, exp: exp }, api_secret)
    end

    def self.decode(token)
      # `JWT.token()` return `[payload, header]`, we use `.first` to retrieve the decode token.
      JWT.decode(token, api_secret).first
    rescue StandardError
      {}
    end

    def self.api_secret
      api_secret = ENV.fetch("JWT_SECRET_TOKEN", nil)
      raise "JWT_SECRET_TOKEN environment variable must be set" if api_secret.blank?
      api_secret
    end
  end
end
