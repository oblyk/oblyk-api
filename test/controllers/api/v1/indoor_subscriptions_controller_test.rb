# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class IndoorSubscriptionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @indoor_subscription = indoor_subscriptions(:subscription_active)
        @product = indoor_subscription_products(:product_one)
        @admin = users(:super_admin_user)
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user) # gym_route_setter_user is also gym admin but check roles
      end

      test 'should get index' do
        get api_v1_gym_indoor_subscriptions_url(gym_id: @gym.id), headers: @admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show indoor subscription' do
        get api_v1_gym_indoor_subscription_url(gym_id: @gym.id, id: @indoor_subscription.id), headers: @admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @indoor_subscription.id, json_response['id']
      end

      test 'should create indoor subscription' do
        # Mock Stripe calls
        Stripe::Plan.stub :create, OpenStruct.new(id: 'plan_123') do
          Stripe::PaymentLink.stub :create, OpenStruct.new(id: 'pl_123', url: 'https://stripe.com/pay') do
            assert_difference('IndoorSubscription.count', 1) do
              post api_v1_gym_indoor_subscriptions_url(gym_id: @gym.id),
                   params: {
                     indoor_subscription: {
                       indoor_subscription_product_id: @product.id,
                       billing_account_email: 'billing@test.com'
                     }
                   },
                   headers: @admin_headers, as: :json
            end
            assert_response :success
          end
        end
      end

      test 'should update indoor subscription' do
        patch api_v1_gym_indoor_subscription_url(gym_id: @gym.id, id: @indoor_subscription.id),
              params: {
                gym: {
                  month_by_occurrence: 6
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @indoor_subscription.reload
        assert_equal 6, @indoor_subscription.month_by_occurrence
      end

      test 'should get figures' do
        get figures_api_v1_gym_indoor_subscriptions_url(gym_id: @gym.id), headers: @admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.has_key?('free_trial_is_available')
      end

      test 'should not access if not authorized' do
        # other_user n'est pas admin de la salle
        other_headers = api_headers(user: :other_user)
        get api_v1_gym_indoor_subscriptions_url(gym_id: @gym.id), headers: other_headers
        assert_response :unauthorized
      end

      test 'should not access if user does not have manage_subscription role' do
        # gym_route_setter_user est admin de la salle mais n'a pas le rôle manage_subscription
        # gym_administrator_two (gym_route_setter_user) a ["manage_space", "manage_opening"]
        get api_v1_gym_indoor_subscriptions_url(gym_id: @gym.id), headers: @user_headers
        assert_response :forbidden
      end
    end
  end
end
