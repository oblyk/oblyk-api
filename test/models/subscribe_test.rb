# frozen_string_literal: true

require 'test_helper'

class SubscribeTest < ActiveSupport::TestCase
  setup do
    @subscribe = subscribes(:one)
  end

  test 'is valid with valid attributes' do
    assert @subscribe.valid?
  end

  test 'is invalid without email' do
    @subscribe.email = nil
    assert_not @subscribe.valid?
  end

  test 'is invalid with bad email format' do
    @subscribe.email = 'bad-email'
    assert_not @subscribe.valid?
  end

  test 'is invalid if email is already taken on create' do
    duplicate = Subscribe.new(email: @subscribe.email)
    assert_not duplicate.valid?
  end

  test 'init_subscribed_at before validation' do
    new_subscribe = Subscribe.new(email: 'new@oblyk.org')
    new_subscribe.valid?
    assert_not_nil new_subscribe.subscribed_at
  end

  test 'init_error_counter before validation' do
    new_subscribe = Subscribe.new(email: 'new@oblyk.org')
    new_subscribe.valid?
    assert_equal 0, new_subscribe.error
  end

  test 'scope sendable' do
    sendables = Subscribe.sendable
    assert_includes sendables, subscribes(:one)
    assert_not_includes sendables, subscribes(:two)
    assert_not_includes sendables, subscribes(:complained)
  end

  test 'summary_to_json returns detail_to_json' do
    assert_equal @subscribe.detail_to_json, @subscribe.summary_to_json
  end

  test 'detail_to_json returns expected keys' do
    json = @subscribe.detail_to_json
    assert_equal @subscribe.email, json[:email]
    assert_equal @subscribe.subscribed_at, json[:subscribed_at]
    assert_includes json.keys, :history
    assert_includes json[:history].keys, :created_at
    assert_includes json[:history].keys, :updated_at
  end
end
