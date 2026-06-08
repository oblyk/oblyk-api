# frozen_string_literal: true

require 'test_helper'

class NotificationChannelTest < ActionCable::Channel::TestCase
  test 'subscribes to a stream when user id is present' do
    user = users(:normal_user)
    stub_connection current_user: user

    subscribe

    assert_has_stream "notification_#{user.id}"
  end

  test 'stops all streams when subscribing' do
    user = users(:normal_user)
    stub_connection current_user: user

    subscribe

    assert_has_stream "notification_#{user.id}"
  end

  test 'unsubscribed stops all streams' do
    user = users(:normal_user)
    stub_connection current_user: user
    subscribe

    unsubscribe

    assert_no_streams
  end
end
