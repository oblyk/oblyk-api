# frozen_string_literal: true

class IndoorSubscriptionChecksWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform
    # Subscription ends (the day before)
    finished_subscriptions = IndoorSubscription.where(end_date: Date.current - 1.day)
    finished_subscriptions.find_each do |subscription|
      subscription.update_gym_plans!
      result_plan = subscription.gyms.first.plan
      next if result_plan != 'free'

      IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                              .end_indoor_subscription
                              .deliver_later
    end

    # End of trial period in one week's time
    subscriptions_free_trial_ended_soon = IndoorSubscription.where(trial_end_date: Date.current - 1.week)
    subscriptions_free_trial_ended_soon.find_each do |subscription|
      IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                              .trial_period_ends_soon
                              .deliver_later
    end

    # End of trial period tomorrow
    subscriptions_free_trial_ended_soon = IndoorSubscription.where(trial_end_date: Date.current + 1.day)
    subscriptions_free_trial_ended_soon.find_each do |subscription|
      IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                              .trial_period_ends_tomorrow
                              .deliver_later
    end

    # Perform each day
    IndoorSubscriptionChecksWorker.perform_at((Date.tomorrow.beginning_of_day + 7.hours))
  end
end
