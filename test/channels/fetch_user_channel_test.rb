# frozen_string_literal: true

require 'test_helper'

class FetchUserChannelTest < ActionCable::Channel::TestCase
  test 'subscribes to a stream when user is present' do
    user = users(:normal_user)
    stub_connection current_user: user

    subscribe

    assert_has_stream "fetch_user_#{user.id}"
  end

  test 'unsubscribed stops all streams' do
    user = users(:normal_user)
    stub_connection current_user: user
    subscribe

    unsubscribe

    assert_no_streams
  end
end
