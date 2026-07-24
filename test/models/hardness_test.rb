# frozen_string_literal: true

require 'test_helper'

class HardnessTest < ActiveSupport::TestCase
  test 'Hardness::LIST is an array' do
    assert_kind_of Array, Hardness::LIST
  end

  test 'Hardness::LIST contains expected values' do
    expected_anchors = %w[
      easy_for_the_grade
      this_grade_is_accurate
      sandbagged
    ]

    assert_equal expected_anchors.sort, Hardness::LIST.sort
  end

  test 'Hardness::LIST is frozen' do
    assert_predicate Hardness::LIST, :frozen?
  end

  test 'Hardness::LIST has 3 elements' do
    assert_equal 3, Hardness::LIST.size
  end
end
