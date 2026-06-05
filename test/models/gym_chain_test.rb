# frozen_string_literal: true

require 'test_helper'

class GymChainTest < ActiveSupport::TestCase
  setup do
    @gym_chain = GymChain.new(
      name: 'Climb Up'
    )
  end

  test 'gym chain is valid' do
    assert @gym_chain.valid?
  end

  test 'gym chain is invalid without name' do
    @gym_chain.name = nil
    assert_not @gym_chain.valid?
  end

  test 'api_access_token is generated' do
    @gym_chain.save
    assert_not_nil @gym_chain.api_access_token
  end

  test 'summary_to_json returns correct keys' do
    @gym_chain.save
    json = @gym_chain.summary_to_json
    assert_equal @gym_chain.id, json[:id]
    assert_equal 'Climb Up', json[:name]
    assert_equal 'climb-up', json[:slug_name]
  end

  test 'detail_to_json returns correct keys' do
    @gym_chain.save
    json = @gym_chain.detail_to_json
    assert_equal @gym_chain.id, json[:id]
    assert_not_nil json[:history]
  end
end
