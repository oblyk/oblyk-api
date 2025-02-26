# frozen_string_literal: true

module Services
  module Stripes
    class WebhooksController < ApplicationController
      def index
        Stripe.api_key = ENV['STRIPE_API_KEY']
        endpoint_secret = ENV['STRIPE_ENDPOINT_SECRET']

        payload = request.body.read

        begin
          event = Stripe::Event.construct_from(
            JSON.parse(payload, symbolize_names: true)
          )
        rescue JSON::ParserError => e
          RorVsWild.record_error(e)
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
            RorVsWild.record_error(e)
            status 400
          end
        end

        # Handle the event
        case event.type
        when 'checkout.session.completed'
          StripeService.fulfill_checkout(event.data.object.id)
        when 'customer.subscription.updated'
          StripeService.customer_subscription_update(event)
        else
          true
        end

        head :ok
      end
    end
  end
end
