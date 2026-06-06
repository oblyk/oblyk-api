# frozen_string_literal: true

require 'test_helper'

class StripeServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
    @checkout_session_id = 'cs_test_123'
    @gym_billing_account = gym_billing_accounts(:account_1)
    @gym = gyms(:my_gym)
    @gym.update!(gym_billing_account: @gym_billing_account)

    @indoor_subscription = indoor_subscriptions(:subscription_free_trial)
    IndoorSubscriptionGym.create!(indoor_subscription: @indoor_subscription, gym: @gym)
  end

  test 'fulfill_checkout returns false if already processed' do
    StripeCheckoutSession.create!(checkout_session_id: @checkout_session_id, processed_at: Time.zone.now)

    result = StripeService.fulfill_checkout(@checkout_session_id)
    assert_not result
  end

  test 'fulfill_checkout processes successful payment' do
    # Mock de Stripe::Checkout::Session.retrieve
    metadata = OpenStruct.new(
      gym_billing_account_uuid: @gym_billing_account.uuid,
      indoor_subscription_id: @indoor_subscription.id
    )

    mock_session = OpenStruct.new(
      metadata: metadata,
      customer: 'cus_new_123',
      payment_status: 'paid',
      subscription: 'sub_stripe_123'
    )

    Stripe::Checkout::Session.stub :retrieve, mock_session do
      StripeService.stub :deactivated_payment_link, true do
        assert_emails 1 do
          StripeService.fulfill_checkout(@checkout_session_id)
        end
      end
    end

    @gym_billing_account.reload
    @indoor_subscription.reload

    assert_equal 'cus_new_123', @gym_billing_account.customer_stripe_id
    assert_equal 'sub_stripe_123', @indoor_subscription.subscription_stripe_id
    assert_equal IndoorSubscription::PAID_STATUS, @indoor_subscription.payment_status

    stripe_session = StripeCheckoutSession.find_by(checkout_session_id: @checkout_session_id)
    assert stripe_session.processed?
  end

  test 'deactivated_payment_link updates stripe payment link' do
    payment_link_id = 'pl_123'
    mock_update = Minitest::Mock.new
    mock_update.expect :call, true, [payment_link_id, { active: false }]

    Stripe::PaymentLink.stub :update, mock_update do
      StripeService.deactivated_payment_link(payment_link_id)
    end

    mock_update.verify
  end

  test 'customer_subscription_update handles cancellation' do
    @indoor_subscription.update!(subscription_stripe_id: 'sub_123')

    canceled_at = Time.zone.now
    cancel_at = 1.month.from_now

    mock_event = OpenStruct.new(
      data: OpenStruct.new(
        object: OpenStruct.new(
          id: 'sub_123',
          canceled_at: canceled_at.to_i,
          cancel_at: cancel_at.to_i
        )
      )
    )

    assert_emails 1 do
      StripeService.customer_subscription_update(mock_event)
    end

    @indoor_subscription.reload
    assert_not_nil @indoor_subscription.cancelled_at
    assert_equal cancel_at.to_date, @indoor_subscription.end_date
  end

  test 'customer_subscription_update handles un-cancellation' do
    @indoor_subscription.update!(
      subscription_stripe_id: 'sub_123',
      cancelled_at: Time.zone.now,
      end_date: 1.month.from_now.to_date
    )

    mock_event = OpenStruct.new(
      data: OpenStruct.new(
        object: OpenStruct.new(
          id: 'sub_123',
          canceled_at: nil
        )
      )
    )

    assert_emails 1 do
      StripeService.customer_subscription_update(mock_event)
    end

    @indoor_subscription.reload
    assert_nil @indoor_subscription.cancelled_at
    assert_nil @indoor_subscription.end_date
  end
end
