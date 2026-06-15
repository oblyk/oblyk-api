# frozen_string_literal: true

require 'test_helper'

class GymMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:normal_user)
    @gym = gyms(:my_gym)
    ENV['SEND_EMAIL_WITH'] = 'smtp'
    ENV['SEND_IN_BLUE_REPLY_EMAIL'] = 'reply@oblyk.org'
    ENV['SMTP_USER_NAME'] = 'admin@oblyk.org'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'new_request' do
    params = {
      user: @user,
      gym: @gym,
      email: 'test@example.com',
      justification: 'Je suis le gérant',
      first_name: 'Jean',
      last_name: 'Jack'
    }
    email = GymMailer.with(params).new_request

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ENV['SMTP_USER_NAME']], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'new_request with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    params = {
      user: @user,
      gym: @gym,
      email: 'test@example.com',
      justification: 'Je suis le gérant',
      first_name: 'Jean',
      last_name: 'Jack'
    }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      GymMailer.with(params).new_request.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'new_request_confirmation' do
    params = {
      gym: @gym,
      email: 'test@example.com',
      first_name: 'Jean'
    }
    email = GymMailer.with(params).new_request_confirmation

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['test@example.com'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'new_request_confirmation with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    params = {
      gym: @gym,
      email: 'test@example.com',
      first_name: 'Jean'
    }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      GymMailer.with(params).new_request_confirmation.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'new_administrator' do
    params = {
      user: @user,
      host: users(:super_admin_user),
      gym: @gym,
      requested_email: 'admin@gym.com'
    }
    email = GymMailer.with(params).new_administrator

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['admin@gym.com'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'new_administrator with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    params = {
      user: @user,
      host: users(:super_admin_user),
      gym: @gym,
      requested_email: 'admin@gym.com'
    }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      GymMailer.with(params).new_administrator.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'accept_administrator' do
    params = {
      user: @user,
      gym: @gym,
      email: 'admin@gym.com'
    }
    email = GymMailer.with(params).accept_administrator

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['admin@gym.com'], email.to
    assert_match /#{@gym.name}/, email.subject
  end

  test 'accept_administrator with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    params = {
      user: @user,
      gym: @gym,
      email: 'admin@gym.com'
    }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      GymMailer.with(params).accept_administrator.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'email_report' do
    params = {
      user: @user,
      figures: {},
      start_date: Date.current.beginning_of_month,
      end_date: Date.current.end_of_month
    }
    email = GymMailer.with(params).email_report

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match /rapport/, email.subject
  end

  test 'email_report with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    params = {
      user: @user,
      figures: {},
      start_date: Date.current.beginning_of_month,
      end_date: Date.current.end_of_month
    }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      GymMailer.with(params).email_report.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
