# frozen_string_literal: true

require 'test_helper'

class SendPublicationsEmailsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
    @user = users(:normal_user)
    @user.update_column(:email_notifiable_list, ['new_publication'])

    @crag = crags(:rocher_des_aures)
    @publication = Publication.create!(
      publishable: @crag,
      published_at: 1.day.ago,
      body: 'Yesterday publication'
    )

    @notification = Notification.create!(
      user: @user,
      notifiable: @publication,
      notification_type: 'new_publication',
      posted_at: 1.day.ago
    )
  end

  test 'it sends emails for yesterday publications' do
    assert_emails 1 do
      SendPublicationsEmailsJob.perform_now
    end

    @notification.reload
    assert_not_nil @notification.email_notification_sent_at
  end

  test 'it does not send email if user has not opted in' do
    @user.update_column(:email_notifiable_list, [])

    assert_no_emails do
      SendPublicationsEmailsJob.perform_now
    end
  end

  test 'it does not send email if notification is from today' do
    @notification.update_column(:posted_at, Time.current)

    assert_no_emails do
      SendPublicationsEmailsJob.perform_now
    end
  end

  test 'it does not send email if notification is already read' do
    @notification.update_column(:read_at, Time.current)

    assert_no_emails do
      SendPublicationsEmailsJob.perform_now
    end
  end

  test 'it does not send email if email is already sent' do
    @notification.update_column(:email_notification_sent_at, Time.current)

    assert_no_emails do
      SendPublicationsEmailsJob.perform_now
    end
  end

  test 'it reschedules itself for tomorrow at 9am' do
    travel_to Time.zone.local(2026, 5, 8, 14, 0, 0) do
      assert_enqueued_with(job: SendPublicationsEmailsJob, at: Time.zone.local(2026, 5, 9, 9, 0, 0)) do
        SendPublicationsEmailsJob.perform_now
      end
    end
  end
end
