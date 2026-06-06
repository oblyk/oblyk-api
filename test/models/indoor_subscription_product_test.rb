# frozen_string_literal: true

require 'test_helper'

class IndoorSubscriptionProductTest < ActiveSupport::TestCase
  setup do
    @product = indoor_subscription_products(:product_one)
  end

  test 'validations' do
    @product.reference = nil
    assert_not @product.valid?

    @product.reference = 'ref'
    @product.price_cents = nil
    assert_not @product.valid?

    @product.price_cents = 1000
    @product.month_by_occurrence = 2
    assert_not @product.valid?

    @product.month_by_occurrence = 3
    assert @product.valid?
  end

  test 'detail_to_json' do
    json = @product.detail_to_json
    assert_equal @product.id, json[:id]
    assert_equal @product.reference, json[:reference]
    assert_equal @product.price_cents, json[:price][:cents]
  end
end
