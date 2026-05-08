# frozen_string_literal: true

require 'test_helper'

class StartTest < ActiveSupport::TestCase
  test 'Start::LIST is an array' do
    assert Start::LIST.is_a?(Array)
  end

  test 'Start::LIST contains expected values' do
    expected_anchors = %w[
      sit
      down
      stand
      jump
      run_and_jump
    ]
    assert_equal expected_anchors.sort, Start::LIST.sort
  end

  test 'Start::LIST is frozen' do
    assert Start::LIST.frozen?
  end

  test 'Start::LIST has 5 elements' do
    assert_equal 5, Start::LIST.size
  end
end
