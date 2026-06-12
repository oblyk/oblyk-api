# frozen_string_literal: true
require 'test_helper'

module Services
  module Stripes
    class WebhooksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @endpoint_secret = 'whsec_test_secret'
        ENV['STRIPE_ENDPOINT_SECRET'] = @endpoint_secret
        ENV['STRIPE_API_KEY'] = 'sk_test_key'
      end

      test 'should handle checkout.session.completed event' do
        payload = {
          id: 'evt_123',
          type: 'checkout.session.completed',
          data: {
            object: {
              id: 'cs_test_123'
            }
          }
        }.to_json

        # We mock Stripe::Webhook.construct_event to avoid real signature verification
        # as it is hard to reproduce in test without the private key of stripe
        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
        Stripe::Webhook.stub :construct_event, event do
          StripeService.stub :fulfill_checkout, true do
            post services_stripes_webhook_path, params: payload, headers: { 'HTTP_STRIPE_SIGNATURE' => 'valid_signature' }
            assert_response :success
          end
        end
      end

      test 'should handle customer.subscription.updated event' do
        payload = {
          id: 'evt_456',
          type: 'customer.subscription.updated',
          data: {
            object: {
              id: 'sub_test_456'
            }
          }
        }.to_json

        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
        Stripe::Webhook.stub :construct_event, event do
          StripeService.stub :customer_subscription_update, true do
            post services_stripes_webhook_path, params: payload, headers: { 'HTTP_STRIPE_SIGNATURE' => 'valid_signature' }
            assert_response :success
          end
        end
      end

      test 'should return success for unhandled event types' do
        payload = {
          id: 'evt_789',
          type: 'unhandled.event',
          data: {
            object: {}
          }
        }.to_json

        event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
        Stripe::Webhook.stub :construct_event, event do
          post services_stripes_webhook_path, params: payload, headers: { 'HTTP_STRIPE_SIGNATURE' => 'valid_signature' }
          assert_response :success
        end
      end
    end
  end
end
