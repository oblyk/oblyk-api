# frozen_string_literal: true

require 'test_helper'

class GymSpaceTest < ActiveSupport::TestCase
  setup do
    @gym_space = gym_spaces(:my_gym_boulder_space)
  end

  test 'gym_space is valid' do
    assert @gym_space.valid?
  end

  test 'gym_space is invalid without name' do
    @gym_space.name = nil
    assert_not @gym_space.valid?
  end

  test 'gym_space is invalid with incorrect climbing_type' do
    @gym_space.climbing_type = 'invalid_type'
    assert_not @gym_space.valid?
  end

  test 'gym_space app_path returns correct path' do
    assert_equal "/gyms/#{@gym_space.gym_id}/#{@gym_space.gym.slug_name}/spaces/#{@gym_space.id}/#{@gym_space.slug_name}", @gym_space.app_path
  end

  test 'gym_space summary_to_json returns correct keys' do
    summary = @gym_space.summary_to_json
    assert_equal @gym_space.id, summary[:id]
    assert_equal @gym_space.name, summary[:name]
    assert_includes summary.keys, :gym
  end
end
