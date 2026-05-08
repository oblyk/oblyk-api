# frozen_string_literal: true

require 'test_helper'

class RopingStatusTest < ActiveSupport::TestCase
  test 'RopingStatus::LIST is an array' do
    assert RopingStatus::LIST.is_a?(Array)
  end

  test 'RopingStatus::LIST contains expected values' do
    expected_anchors = %w[
      lead_climb
      top_rope
      multi_pitch_leader
      multi_pitch_second
      multi_pitch_alternate_lead
    ]
    assert_equal expected_anchors.sort, RopingStatus::LIST.sort
  end

  test 'RopingStatus::LIST is frozen' do
    assert RopingStatus::LIST.frozen?
  end

  test 'RopingStatus::LIST has 5 elements' do
    assert_equal 5, RopingStatus::LIST.size
  end
end
