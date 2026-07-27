# frozen_string_literal: true

require "test_helper"

class AscentStatusTest < ActiveSupport::TestCase
  test "AscentStatus::LIST is an array" do
    assert_kind_of Array, AscentStatus::LIST
  end

  test "AscentStatus::LIST contains expected values" do
    expected_ascent_status = %w[
      project
      sent
      red_point
      flash
      onsight
      repetition
    ]

    assert_equal expected_ascent_status.sort, AscentStatus::LIST.sort
  end

  test "AscentStatus::LIST is frozen" do
    assert_predicate AscentStatus::LIST, :frozen?
  end

  test "AscentStatus::LIST has 6 elements" do
    assert_equal 6, AscentStatus::LIST.size
  end

  test "AscentStatus::FIRST_TOP_LIST is an array" do
    assert_kind_of Array, AscentStatus::FIRST_TOP_LIST
  end

  test "AscentStatus::FIRST_TOP_LIST contains expected values" do
    expected_ascent_status = %w[
      sent
      red_point
      flash
      onsight
    ]

    assert_equal expected_ascent_status.sort, AscentStatus::FIRST_TOP_LIST.sort
  end

  test "AscentStatus::FIRST_TOP_LIST is frozen" do
    assert_predicate AscentStatus::FIRST_TOP_LIST, :frozen?
  end

  test "AscentStatus::FIRST_TOP_LIST has 4 elements" do
    assert_equal 4, AscentStatus::FIRST_TOP_LIST.size
  end
end
