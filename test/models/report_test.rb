# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @report_on_crag = reports(:report_on_crag)
    @user = users(:normal_user)
    @crag = crags(:rocher_des_aures)
  end

  test 'report is valid' do
    assert @report_on_crag.valid?
  end

  test 'validates reportable type inclusion' do
    report = Report.new(
      reportable_type: 'Crag',
      reportable_id: @crag.id,
      body: 'Test body',
      user: @user
    )
    assert report.valid?

    report.reportable_type = 'NotAModel'
    begin
      is_invalid = report.invalid?
    rescue NameError, RuntimeError
      is_invalid = true
    end
    assert is_invalid
  end

  test 'associations' do
    assert_equal @user, @report_on_crag.user
    assert_equal @crag, @report_on_crag.reportable
  end

  test 'send_email_notification after create' do
    report = Report.new(
      reportable: @crag,
      body: 'Testing email notification',
      user: @user,
      report_from_url: 'https://oblyk.org/test'
    )

    assert_enqueued_emails 1 do
      report.save!
    end
  end
  test 'strip body tags before validation' do
    report = Report.new(
      reportable: @crag,
      body: 'I have a <b>link</b>',
      user: @user
    )
    report.validate
    assert_equal 'I have a link', report.body
  end
end
