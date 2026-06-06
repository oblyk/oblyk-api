# frozen_string_literal: true

require 'test_helper'

class IndoorSubscriptionTest < ActiveSupport::TestCase
  setup do
    @active = indoor_subscriptions(:subscription_active)
    @expired = indoor_subscriptions(:subscription_expired)
    @trial = indoor_subscriptions(:subscription_free_trial)
    @gym = gyms(:my_gym)
    @product = indoor_subscription_products(:product_one)
  end

  test 'scope active' do
    active_subscriptions = IndoorSubscription.active
    assert_includes active_subscriptions, @active
    assert_includes active_subscriptions, @trial
    assert_not_includes active_subscriptions, @expired
  end

  test 'active? and expired?' do
    assert @active.active?
    assert_not @active.expired?

    assert @expired.expired?
    assert_not @expired.active?
  end

  test 'in_free_trial?' do
    assert @trial.in_free_trial?
    assert_not @active.in_free_trial?
  end

  test 'create_payment_link!' do
    ENV['STRIPE_API_KEY'] = 'sk_test_123'

    plan_id = 'plan_123'

    mock_payment_link = Minitest::Mock.new
    mock_payment_link.expect :id, 'plink_123'
    mock_payment_link.expect :url, 'https://stripe.com/pay'

    plan_struct = OpenStruct.new(id: plan_id)

    Stripe::Plan.stub :create, plan_struct do
      Stripe::PaymentLink.stub :create, mock_payment_link do
        @active.create_payment_link!(@product, @gym)
      end
    end

    assert_equal 'plink_123', @active.payment_link_stipe_id
    assert_match /https:\/\/stripe.com\/pay/, @active.payment_link
    assert_mock mock_payment_link
  end

  test 'cancel! sends email' do
    mock_mailer = Minitest::Mock.new
    mock_mail = Minitest::Mock.new

    mock_mailer.expect :cancel_indoor_subscription, mock_mail
    mock_mail.expect :deliver_later, nil

    IndoorSubscriptionMailer.stub :with, mock_mailer, [indoor_subscription: @active] do
      @active.cancel!(Time.current, Date.current + 1.month)
    end

    assert_not_nil @active.cancelled_at
    assert_mock mock_mailer
    assert_mock mock_mail
  end

  test 'un_cancel! sends email' do
    @active.update_columns(cancelled_at: Time.current, end_date: Date.current + 1.month)

    mock_mailer = Minitest::Mock.new
    mock_mail = Minitest::Mock.new

    mock_mailer.expect :un_cancel_indoor_subscription, mock_mail
    mock_mail.expect :deliver_later, nil

    IndoorSubscriptionMailer.stub :with, mock_mailer, [indoor_subscription: @active] do
      @active.un_cancel!
    end

    assert_nil @active.cancelled_at
    assert_nil @active.end_date
    assert_mock mock_mailer
    assert_mock mock_mail
  end

  test 'detail_to_json' do
    json = @active.detail_to_json
    assert_equal @active.id, json[:id]
    assert_equal @active.for_gym_type, json[:for_gym_type]
    assert_equal @active.active?, json[:active_subscription]
  end
end
