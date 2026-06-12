# frozen_string_literal: true

require 'test_helper'

class IndoorSubscriptionChecksJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @gym = gyms(:my_gym)
    @subscription = indoor_subscriptions(:subscription_active)
    IndoorSubscriptionGym.find_or_create_by!(gym: @gym, indoor_subscription: @subscription)
  end

  test 'it sends email and updates plan when subscription ended yesterday' do
    IndoorSubscriptionGym.where(gym: @gym).where.not(indoor_subscription: @subscription).destroy_all
    @subscription.update_columns(
      end_date: Date.current - 1.day,
      start_date: Date.current - 1.month
    )
    @gym.update_column(:plan, 'full_package')

    assert_enqueued_emails 1 do
      IndoorSubscriptionChecksJob.perform_now
    end

    @gym.reload
    assert_equal 'free', @gym.plan
  end

  test 'it sends email when trial period ends in one week' do
    @subscription.update_columns(trial_end_date: Date.current - 1.week)

    assert_enqueued_emails 1 do
      IndoorSubscriptionChecksJob.perform_now
    end
  end

  test 'it sends email when trial period ends tomorrow' do
    @subscription.update_columns(trial_end_date: Date.current + 1.day)

    assert_enqueued_emails 1 do
      IndoorSubscriptionChecksJob.perform_now
    end
  end

  test 'it schedules the next job for tomorrow' do
    IndoorSubscriptionChecksJob.perform_now

    next_run = Date.tomorrow.beginning_of_day + 7.hours
    assert_enqueued_with(job: IndoorSubscriptionChecksJob, at: next_run)
  end
end
