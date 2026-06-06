# frozen_string_literal: true

require 'test_helper'

class StripeCheckoutSessionTest < ActiveSupport::TestCase
  test 'should return true if processed_at is present' do
    assert stripe_checkout_sessions(:one).processed?
  end

  test 'should return false if processed_at is nil' do
    assert_not stripe_checkout_sessions(:two).processed?
  end

  test 'processed! should set processed_at and save' do
    session = StripeCheckoutSession.new(checkout_session_id: 'cs_test_123')
    assert_nil session.processed_at
    
    session.processed!
    
    assert_not_nil session.processed_at
    assert session.processed?
    assert_predicate session, :persisted?
  end
end
