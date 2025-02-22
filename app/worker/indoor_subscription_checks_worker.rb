# frozen_string_literal: true

class IndoorSubscriptionChecksWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform
    # Subscription ends the day before
    finished_subscriptions = IndoorSubscription.where(end_date: Date.current - 1.day)
    finished_subscriptions.find_each do |subscription|
      subscription.update_gym_plans!
      result_plan = subscription.gyms.first.plan
      next if result_plan != 'free'

      if subscription.for_free_trial
        IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                                .end_trial_period
                                .deliver_now
      else
        IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                                .end_indoor_subscription
                                .deliver_now
      end
    end

    # End of trial period in one week's time
    subscriptions_free_trial_ended_soon = IndoorSubscription.where(end_date: Date.current - 1.week, for_free_trial: true)
    subscriptions_free_trial_ended_soon.find_each do |subscription|
      next if subscription.next_paying_subscription?

      IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                              .trial_period_ends_soon
                              .deliver_now
    end

    # End of trial period tomorrow
    subscriptions_free_trial_ended_soon = IndoorSubscription.where(end_date: Date.current + 1.day, for_free_trial: true)
    subscriptions_free_trial_ended_soon.find_each do |subscription|
      next if subscription.next_paying_subscription?

      IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                              .trial_period_ends_tomorrow
                              .deliver_now
    end

    # Perform each day at 8 am
    GymReportingWorker.perform_at(Date.current.beginning_of_day) + 7.hours
  end
end
