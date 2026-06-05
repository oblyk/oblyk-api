# frozen_string_literal: true

require 'test_helper'

class GymChainAdministratorTest < ActiveSupport::TestCase
  setup do
    @gym_chain_administrator = GymChainAdministrator.new(
      user: users(:normal_user),
      gym_chain: gym_chains(:arkose)
    )
  end

  test 'gym chain administrator is valid' do
    assert @gym_chain_administrator.valid?
  end

  test 'summary_to_json returns correct keys' do
    @gym_chain_administrator.save
    json = @gym_chain_administrator.summary_to_json
    assert_equal @gym_chain_administrator.id, json[:id]
    assert_equal @gym_chain_administrator.user_id, json[:user_id]
    assert_equal @gym_chain_administrator.gym_chain_id, json[:gym_chain_id]
  end
end
