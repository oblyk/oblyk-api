# frozen_string_literal: true

class StripeService
  def self.fulfill_checkout(checkout_session_id)
    Stripe.api_key = ENV['STRIPE_API_KEY']

    stripe_checkout_session = StripeCheckoutSession.find_or_initialize_by checkout_session_id: checkout_session_id
    return false if stripe_checkout_session.processed?

    checkout_session = Stripe::Checkout::Session.retrieve({ id: checkout_session_id, expand: ['line_items'] })

    ActiveRecord::Base.transaction do
      # Update GymBillingAccount
      billing_account = GymBillingAccount.find_by(uuid: checkout_session.metadata.gym_billing_account_uuid)
      if billing_account.present?
        billing_account.customer_stripe_id = checkout_session.customer
        billing_account.save
      end

      # Update subscription
      if checkout_session.payment_status == 'paid' && checkout_session.metadata.indoor_subscription_id.present?
        subscription = IndoorSubscription.find checkout_session.metadata.indoor_subscription_id
        subscription.subscription_stripe_id = checkout_session.subscription
        subscription.payment_status = IndoorSubscription::PAID_STATUS
        subscription.save
        subscription.update_gym_plans!
        stripe_checkout_session.processed!
        StripeService.deactivated_payment_link(subscription.payment_link_stipe_id)

        if subscription.in_free_trial?
          IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                                  .start_trial_period
                                  .deliver_later
        else
          IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                                  .start_indoor_subscription
                                  .deliver_later
        end
      end
    end
  end

  def self.deactivated_payment_link(payment_link_id)
    Stripe.api_key = ENV['STRIPE_API_KEY']
    Stripe::PaymentLink.update(payment_link_id, { active: false })
  end

  def self.customer_subscription_update(event)
    indoor_subscription = IndoorSubscription.find_by subscription_stripe_id: event.data.object.id
    return unless indoor_subscription

    if event.data.object.canceled_at.blank?
      indoor_subscription.un_cancel!
    else
      indoor_subscription.cancel!(
        Time.zone.at(event.data.object.canceled_at),
        Time.zone.at(event.data.object.cancel_at).to_date
      )
    end
    indoor_subscription.update_gym_plans!
  end
end
