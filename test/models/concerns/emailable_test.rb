# frozen_string_literal: true

require 'test_helper'

class EmailableTest < ActiveSupport::TestCase
  test 'normalize_email strips and downcases email' do
    user = User.new(email: '  TEST@Example.Com  ')
    user.valid?
    assert_equal 'test@example.com', user.email
  end

  test 'normalize_email strips and downcases requested_email' do
    administrator = GymAdministrator.new(requested_email: '  NEW@Example.Com  ')
    administrator.valid?
    assert_equal 'new@example.com', administrator.requested_email
  end
end
