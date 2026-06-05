# frozen_string_literal: true

require 'test_helper'

class GymChainGymTest < ActiveSupport::TestCase
  setup do
    @gym_chain_gym = GymChainGym.new(
      gym: gyms(:my_gym),
      gym_chain: gym_chains(:arkose)
    )
  end

  test 'gym chain gym is valid' do
    assert @gym_chain_gym.valid?
  end

  test 'summary_to_json returns correct keys' do
    @gym_chain_gym.save
    json = @gym_chain_gym.summary_to_json
    assert_equal @gym_chain_gym.id, json[:id]
    assert_equal @gym_chain_gym.gym_id, json[:gym_id]
    assert_equal @gym_chain_gym.gym_chain_id, json[:gym_chain_id]
  end
end
