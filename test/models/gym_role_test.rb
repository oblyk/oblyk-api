# frozen_string_literal: true

require 'test_helper'

class GymRoleTest < ActiveSupport::TestCase
  test 'GymRole::LIST is an array' do
    assert GymRole::LIST.is_a?(Array)
  end

  test 'GymRole::LIST contains expected values' do
    expected_anchors = %w[
      manage_team_member
      manage_opening
      manage_opener
      manage_space
      manage_gym
      manage_subscription
    ]
    assert_equal expected_anchors.sort, GymRole::LIST.sort
  end

  test 'GymRole::LIST is frozen' do
    assert GymRole::LIST.frozen?
  end

  test 'GymRole::LIST has 6 elements' do
    assert_equal 6, GymRole::LIST.size
  end
end
