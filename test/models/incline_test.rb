# frozen_string_literal: true

require "test_helper"

class InclineTest < ActiveSupport::TestCase
  test "Incline::LIST is an array" do
    assert_kind_of Array, Incline::LIST
  end

  test "Incline::LIST contains expected values" do
    expected_anchors = %w[
      slab
      vertical
      slight_overhang
      overhang
      roof
    ]

    assert_equal expected_anchors.sort, Incline::LIST.sort
  end

  test "Incline::LIST is frozen" do
    assert_predicate Incline::LIST, :frozen?
  end

  test "Incline::LIST has 5 elements" do
    assert_equal 5, Incline::LIST.size
  end
end
