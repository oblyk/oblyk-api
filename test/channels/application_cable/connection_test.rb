# frozen_string_literal: true

require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test 'connects with valid token' do
      user = users(:normal_user)
      connect params: { token: "Bearer #{user.ws_token}" }
      assert_equal user.id, connection.current_user.id
    end

    test 'rejects connection without token' do
      assert_reject_connection do
        connect
      end
    end

    test 'rejects connection with invalid token' do
      assert_reject_connection do
        connect params: { token: 'Bearer invalid-token' }
      end
    end

    test 'rejects connection with malformed token' do
      assert_reject_connection do
        connect params: { token: 'malformedtoken' }
      end
    end
  end
end
