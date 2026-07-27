# frozen_string_literal: true

require "test_helper"

class BoltTest < ActiveSupport::TestCase
  test "Bolt::LIST is an array" do
    assert_kind_of Array, Bolt::LIST
  end

  test "Bolt::LIST contains expected values" do
    expected_anchors = %w[
      forged_eye_bolts
      bolt_hangers
      open_staple_bolts
      staple_u_bolts
      no_bolts
    ]

    assert_equal expected_anchors.sort, Bolt::LIST.sort
  end

  test "Bolt::LIST is frozen" do
    assert_predicate Bolt::LIST, :frozen?
  end

  test "Bolt::LIST has 5 elements" do
    assert_equal 5, Bolt::LIST.size
  end
end
