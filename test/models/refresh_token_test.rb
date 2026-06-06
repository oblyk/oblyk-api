# frozen_string_literal: true

require 'test_helper'

class RefreshTokenTest < ActiveSupport::TestCase
  setup do
    @refresh_token = refresh_tokens(:one)
    @user = users(:normal_user)
  end

  test 'refresh token is valid' do
    assert @refresh_token.valid?
  end

  test 'token must be present' do
    @refresh_token.token = nil
    assert_not @refresh_token.valid?
    assert_includes @refresh_token.errors[:token], 'is_mandatory'
  end

  test 'user_agent must be present' do
    @refresh_token.user_agent = nil
    assert_not @refresh_token.valid?
    assert_includes @refresh_token.errors[:user_agent], 'is_mandatory'
  end

  test 'token must be unique' do
    duplicate_token = @refresh_token.dup
    @refresh_token.save
    assert_not duplicate_token.valid?
    assert_includes duplicate_token.errors[:token], 'is_already_taken'
  end

  test 'belongs to user' do
    assert_instance_of User, @refresh_token.user
  end

  test 'unused_token generates a unique token' do
    token = RefreshToken.new(user: @user, user_agent: 'Firefox')
    token.unused_token
    assert_not_nil token.token
    assert_not RefreshToken.exists?(token: token.token)
  end

  test 'unused_token replaces existing token' do
    @refresh_token.unused_token
    assert_not_equal 'token_one', @refresh_token.token
  end
end
