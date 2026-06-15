# frozen_string_literal: true

require 'test_helper'

class IndoorSubscriptionMailerTest < ActionMailer::TestCase
  setup do
    @indoor_subscription = indoor_subscriptions(:subscription_active)
    @indoor_subscription.update!(
      trial_end_date: Date.current + 28.days,
      end_date: Date.current + 1.year
    )
    @gym = gyms(:my_gym)
    ENV['SEND_EMAIL_WITH'] = 'smtp'
    ENV['SEND_IN_BLUE_REPLY_EMAIL'] = 'reply@oblyk.org'
    ENV['SMTP_USER_NAME'] = 'admin@oblyk.org'
    ENV['EMAIL_DEFAULT_FROM'] = 'contact@oblyk.org'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'start_trial_period' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).start_trial_period

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'start_trial_period with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).start_trial_period.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'trial_period_ends_soon' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).trial_period_ends_soon

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'trial_period_ends_soon with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).trial_period_ends_soon.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'trial_period_ends_tomorrow' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).trial_period_ends_tomorrow

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'trial_period_ends_tomorrow with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).trial_period_ends_tomorrow.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'start_indoor_subscription' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).start_indoor_subscription

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'start_indoor_subscription with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).start_indoor_subscription.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'cancel_indoor_subscription' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).cancel_indoor_subscription

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'cancel_indoor_subscription with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).cancel_indoor_subscription.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'un_cancel_indoor_subscription' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).un_cancel_indoor_subscription

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'un_cancel_indoor_subscription with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).un_cancel_indoor_subscription.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'end_indoor_subscription' do
    email = IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).end_indoor_subscription

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['contact@oblyk.org'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'end_indoor_subscription with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [Brevo::SendSmtpEmail]

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      IndoorSubscriptionMailer.with(indoor_subscription: @indoor_subscription).end_indoor_subscription.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
