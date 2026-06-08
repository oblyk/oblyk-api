# frozen_string_literal: true

require 'test_helper'

class JwtToken::TokenTest < ActiveSupport::TestCase
  test 'it can generate a token' do
    data = { user_id: 1 }
    token = JwtToken::Token.generate(data)
    assert token.present?
    assert_kind_of String, token
  end

  test 'it can decode a valid token' do
    data = { 'user_id' => 1 }
    token = JwtToken::Token.generate(data)
    decoded = JwtToken::Token.decode(token)

    assert_equal data, decoded['data']
    assert decoded['exp'].present?
  end

  test 'it can generate a token with custom expiration' do
    data = { 'user_id' => 1 }
    exp = Time.now.to_i + 3600
    token = JwtToken::Token.generate(data, exp)
    decoded = JwtToken::Token.decode(token)

    assert_equal exp, decoded['exp']
  end

  test 'it returns an empty hash when decoding an invalid token' do
    decoded = JwtToken::Token.decode('invalid-token')
    assert_equal({}, decoded)
  end

  test 'it returns an empty hash when decoding an expired token' do
    data = { user_id: 1 }
    exp = Time.now.to_i - 3600
    token = JwtToken::Token.generate(data, exp)

    decoded = JwtToken::Token.decode(token)
    assert_equal({}, decoded)
  end

  test 'api_secret returns a default value or env value' do
    secret = JwtToken::Token.api_secret
    assert secret.present?
    assert_kind_of String, secret
  end
end
