# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class IndoorSubscriptionProductsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @product = indoor_subscription_products(:product_one)
        @headers = api_headers
      end

      test 'should get index' do
        get api_v1_gym_indoor_subscription_products_url(gym_id: @gym.id), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show indoor subscription product' do
        get api_v1_gym_indoor_subscription_product_url(gym_id: @gym.id, id: @product.id), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @product.id, json_response['id']
      end
    end
  end
end
