# frozen_string_literal: true

module Services
  module Stripes
    class WebhooksController < ApplicationController
      def index
        Stripe.api_key = ENV['STRIPE_API_KEY']
        endpoint_secret = ENV['STRIPE_ENDPOINT_SECRET']

        payload = request.body.read
        event = nil

        begin
          event = Stripe::Event.construct_from(
            JSON.parse(payload, symbolize_names: true)
          )
        rescue JSON::ParserError => e
          # Invalid payload
          puts "⚠️  Webhook error while parsing basic request. #{e.message}"
          status 400
          return
        end

        # Check if webhook signing is configured.
        if endpoint_secret
          # Retrieve the event by verifying the signature using the raw body and secret.
          signature = request.env['HTTP_STRIPE_SIGNATURE']
          begin
            event = Stripe::Webhook.construct_event(
              payload, signature, endpoint_secret
            )
          rescue Stripe::SignatureVerificationError => e
            puts "⚠️  Webhook signature verification failed. #{e.message}"
            status 400
          end
        end

        # Handle the event
        case event.type
        when 'payment_intent.succeeded'
          # payment_intent = event.data.object # contains a Stripe::PaymentIntent
          # puts "Payment for #{payment_intent['amount']} succeeded."
          # Then define and call a method to handle the successful payment intent.
          # handle_payment_intent_succeeded(payment_intent)
        when 'payment_method.attached'
          # payment_method = event.data.object # contains a Stripe::PaymentMethod
          # Then define and call a method to handle the successful attachment of a PaymentMethod.
          # handle_payment_method_attached(payment_method)
        when 'checkout.session.completed'
          fulfill_checkout(event.data.object.id)
        when 'checkout.session.async_payment_succeeded'
          fulfill_checkout(event.data.object.id)
        when 'customer.subscription.updated'
          customer_subscription_update(event)
        else
          # puts "Unhandled event type: #{event.type}"
        end

        head :ok
      end

      private

      def fulfill_checkout(checkout_session_id)
        Stripe.api_key = ENV['STRIPE_API_KEY']

        stripe_checkout_session = StripeCheckoutSession.find_or_initialize_by checkout_session_id: checkout_session_id
        if stripe_checkout_session.processed?
          return false
        end

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
            deactivated_payment_link(subscription.payment_link_stipe_id)

            IndoorSubscriptionMailer.with(indoor_subscription: subscription)
                                    .start_indoor_subscription
                                    .deliver_now
          end
        end
      end

      def deactivated_payment_link(payment_link_id)
        Stripe.api_key = ENV['STRIPE_API_KEY']
        Stripe::PaymentLink.update(payment_link_id, { active: false })
      end

      def customer_subscription_update(event)
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
  end
end
