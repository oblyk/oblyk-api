# frozen_string_literal: true

require 'test_helper'

class ClimbingStyleTest < ActiveSupport::TestCase
  test 'ClimbingStyle::STYLE_LIST is an array' do
    assert ClimbingStyle::STYLE_LIST.is_a?(Array)
  end

  test 'ClimbingStyle::STYLE_LIST contains expected values' do
    expected_anchors = %w[
      boulder
      endurance
      resistance
      technical
      physics
      finger
      grip
      coordination
      tall_people
      small_people
      balance
      clamp
      volume
      core_strength
      commitment
      precision
      promptness
      dynamic
      complex
      sensation
      basic
      u8
      u9
      u10
      u11
      u12
      u13
      u14
      u15
      u16
      u17
      u18
      u19
    ]
    assert_equal expected_anchors.sort, ClimbingStyle::STYLE_LIST.sort
  end

  test 'ClimbingStyle::STYLE_LIST is frozen' do
    assert ClimbingStyle::STYLE_LIST.frozen?
  end

  test 'ClimbingStyle::STYLE_LIST has 26 elements' do
    assert_equal 33, ClimbingStyle::STYLE_LIST.size
  end
end
