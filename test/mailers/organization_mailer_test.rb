# frozen_string_literal: true

require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  setup do
    @params = {
      organization_id: 1,
      name: 'Oblyk Organization',
      email: 'ekip@oblyk.org',
      api_usage_type: 'commercial'
    }

    ENV['SEND_EMAIL_WITH'] = 'smtp'
    ENV['SMTP_USER_NAME'] = 'ekip@oblyk.org'
    ENV['SEND_IN_BLUE_REPLY_EMAIL'] = 'ekip@oblyk.org'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'new_organization sends email with SMTP' do
    email = OrganizationMailer.with(@params).new_organization

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ENV['SMTP_USER_NAME']], email.to
    assert_equal "[admin] Nouvelle organisation 1", email.subject
    assert_match /Oblyk Organization/, email.html_part.body.to_s
    assert_match /ekip@oblyk.org/, email.html_part.body.to_s
    assert_match /commercial/, email.html_part.body.to_s

    assert_match /Oblyk Organization/, email.text_part.body.to_s
    assert_match /ekip@oblyk.org/, email.text_part.body.to_s
    assert_match /commercial/, email.text_part.body.to_s
  end

  test 'new_organization sends email with SendInBlue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'

    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      OrganizationMailer.with(@params).new_organization.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
