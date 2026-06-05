# frozen_string_literal: true

require 'test_helper'

class IndoorSubscriptionGymTest < ActiveSupport::TestCase
  setup do
    @indoor_subscription_gym = indoor_subscription_gyms(:one)
  end

  test 'indoor subscription gym is valid' do
    assert @indoor_subscription_gym.valid?
  end

  test 'indoor subscription gym is invalid without indoor_subscription' do
    @indoor_subscription_gym.indoor_subscription = nil
    assert_not @indoor_subscription_gym.valid?
  end

  test 'indoor subscription gym is invalid without gym' do
    @indoor_subscription_gym.gym = nil
    assert_not @indoor_subscription_gym.valid?
  end

  test 'destroying jointure does not destroy gym or subscription' do
    gym = @indoor_subscription_gym.gym
    subscription = @indoor_subscription_gym.indoor_subscription
    
    @indoor_subscription_gym.destroy
    
    assert Gym.exists?(gym.id)
    assert IndoorSubscription.exists?(subscription.id)
  end
end
