# frozen_string_literal: true

require 'test_helper'

class ReceptionTest < ActiveSupport::TestCase
  test 'Reception::LIST is an array' do
    assert_kind_of Array, Reception::LIST
  end

  test 'Reception::LIST contains expected values' do
    expected_anchors = %w[
      good
      correct
      bad
      dangerous
    ]

    assert_equal expected_anchors.sort, Reception::LIST.sort
  end

  test 'Reception::LIST is frozen' do
    assert_predicate Reception::LIST, :frozen?
  end

  test 'Reception::LIST has 4 elements' do
    assert_equal 4, Reception::LIST.size
  end
end
