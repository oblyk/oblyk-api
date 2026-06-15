# frozen_string_literal: true

require 'test_helper'

class GymBillingAccountTest < ActiveSupport::TestCase
  setup do
    @gym_billing_account = gym_billing_accounts(:account_1)
    @gym = gyms(:my_gym)
  end

  test 'is valid with email' do
    account = GymBillingAccount.new(email: 'test@test.fr')
    assert account.valid?
  end

  test 'is invalid without email' do
    account = GymBillingAccount.new(email: nil)
    assert_not account.valid?
    assert_includes account.errors[:email], "is_mandatory"
  end

  test 'sets uuid before validation' do
    account = GymBillingAccount.new(email: 'test@test.fr')
    account.validate
    assert_not_nil account.uuid
  end

  test 'summary_to_json returns correct format' do
    summary = @gym_billing_account.summary_to_json
    assert_equal @gym_billing_account.id, summary[:id]
    assert_not_nil summary[:uuid]
    assert_equal @gym_billing_account.email, summary[:email]
  end

  test 'detail_to_json returns correct format' do
    detail = @gym_billing_account.detail_to_json
    assert_equal @gym_billing_account.id, detail[:id]
    assert_not_nil detail[:history][:created_at]
  end

  test 'create_strip_portal! creates a stripe session' do
    mock_session = Minitest::Mock.new
    mock_session.expect :call, true, [
      {
        customer: @gym_billing_account.customer_stripe_id,
        return_url: "#{@gym.admin_app_path}/indoor-subscriptions"
      }
    ]

    Stripe::BillingPortal::Session.stub :create, mock_session do
      @gym_billing_account.create_strip_portal!(@gym)
    end

    assert_mock mock_session
  end

  test 'create_strip_portal! returns nil if customer_stripe_id is blank' do
    @gym_billing_account.customer_stripe_id = nil
    assert_nil @gym_billing_account.create_strip_portal!(@gym)
  end
end
