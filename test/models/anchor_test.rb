# frozen_string_literal: true

require 'test_helper'

class AnchorTest < ActiveSupport::TestCase
  test 'Anchor::LIST is an array' do
    assert Anchor::LIST.is_a?(Array)
  end

  test 'Anchor::LIST contains expected values' do
    expected_anchors = %w[
      bolted_anchor_chains
      bolted_anchor_no_chains
      pigtail_anchors
      traditional_anchor
      no_anchor
    ]
    assert_equal expected_anchors.sort, Anchor::LIST.sort
  end

  test 'Anchor::LIST is frozen' do
    assert Anchor::LIST.frozen?
  end

  test 'Anchor::LIST has 5 elements' do
    assert_equal 5, Anchor::LIST.size
  end
end
