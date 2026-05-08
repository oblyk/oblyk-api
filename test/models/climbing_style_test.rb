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
      u8
      u10
      u12
      u14
      u16
      u18
    ]
    assert_equal expected_anchors.sort, ClimbingStyle::STYLE_LIST.sort
  end

  test 'ClimbingStyle::STYLE_LIST is frozen' do
    assert ClimbingStyle::STYLE_LIST.frozen?
  end

  test 'ClimbingStyle::STYLE_LIST has 26 elements' do
    assert_equal 26, ClimbingStyle::STYLE_LIST.size
  end
end
