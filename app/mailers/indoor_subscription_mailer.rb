# frozen_string_literal: true

class IndoorSubscriptionMailer < ApplicationMailer
  before_action :set_mailer_params

  def start_trial_period
    subject = t('mailer.indoor_subscription.start_trial_period.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/start_trial_period')
    else
      mail(to: @email, subject: subject)
    end
  end

  def trial_period_ends_soon
    subject = t('mailer.indoor_subscription.trial_period_ends_soon.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/trial_period_ends_soon')
    else
      mail(to: @email, subject: subject)
    end
  end

  def trial_period_ends_tomorrow
    subject = t('mailer.indoor_subscription.trial_period_ends_tomorrow.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/trial_period_ends_tomorrow')
    else
      mail(to: @email, subject: subject)
    end
  end

  def end_trial_period
    subject = t('mailer.indoor_subscription.trial_period_ends_tomorrow.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/end_trial_period')
    else
      mail(to: @email, subject: subject)
    end
  end

  def start_indoor_subscription
    subject = t('mailer.indoor_subscription.start_indoor_subscription.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/start_indoor_subscription')
    else
      mail(to: @email, subject: subject)
    end
  end

  def cancel_indoor_subscription
    subject = t('mailer.indoor_subscription.cancel_indoor_subscription.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/cancel_indoor_subscription')
    else
      mail(to: @email, subject: subject)
    end
  end

  def un_cancel_indoor_subscription
    subject = t('mailer.indoor_subscription.un_cancel_indoor_subscription.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/un_cancel_indoor_subscription')
    else
      mail(to: @email, subject: subject)
    end
  end

  def end_indoor_subscription
    subject = t('mailer.indoor_subscription.end_indoor_subscription.title', gym_name: @gym.name)

    if use_send_in_blue?
      send_with_send_in_blue(@email, subject, 'indoor_subscription_mailer/end_indoor_subscription')
    else
      mail(to: @email, subject: subject)
    end
  end

  private

  def set_mailer_params
    @indoor_subscription = params[:indoor_subscription]
    @gym = @indoor_subscription.gyms.first
    @multi_gym = @indoor_subscription.gyms.size >= 2
    @email = @gym.gym_billing_account&.email || @gym.email
  end
end
