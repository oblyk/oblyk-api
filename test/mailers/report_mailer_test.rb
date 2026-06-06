# frozen_string_literal: true

require 'test_helper'

class ReportMailerTest < ActionMailer::TestCase
  setup do
    @report = reports(:report_on_crag)
    @user = users(:normal_user)
    ENV['SEND_EMAIL_WITH'] = 'smtp'
    ENV['SEND_IN_BLUE_REPLY_EMAIL'] = 'reply@oblyk.org'
    ENV['SMTP_USER_NAME'] = 'admin@oblyk.org'
    ENV['EMAIL_DEFAULT_FROM'] = 'contact@oblyk.org'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'new_report' do
    email = ReportMailer.with(
      report_id: @report.id,
      body: @report.body,
      reportable_type: @report.reportable_type,
      reportable_id: @report.reportable_id,
      report_from_url: @report.report_from_url,
      user_full_name: @user.full_name,
      user_id: @user.id,
      user_email: @user.email
    ).new_report

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['admin@oblyk.org'], email.to
    assert_match /#{@report.id}/, email.subject
  end

  test 'new_report with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      ReportMailer.with(
        report_id: @report.id,
        body: @report.body,
        reportable_type: @report.reportable_type,
        reportable_id: @report.reportable_id,
        report_from_url: @report.report_from_url,
        user_full_name: @user.full_name,
        user_id: @user.id,
        user_email: @user.email
      ).new_report.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
