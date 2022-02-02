# frozen_string_literal: true

module JwtToken
  class Token
    # By default, the token is valid for 24 hours
    def self.generate(data, exp = Time.now.to_i + 24 * 3600)
      JWT.encode({ data: data, exp: exp }, api_secret)
    end

    def self.decode(token)
      # `JWT.token()` return `[payload, header]`, we use `.first` to retrieve the decode token.
      JWT.decode(token, api_secret).first
    rescue StandardError
      {}
    end

    def self.api_secret
      ENV.fetch('JWT_SECRET_TOKEN', '9ae75a873a23ddd7f5d91b44a25e95041981d8a0015816264cbd16231092c5734c477154481d0947c8fa09534da2c12a7f09a6a83688a5b0816a1047613ac5ac')
    end
  end
end
