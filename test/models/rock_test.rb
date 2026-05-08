# frozen_string_literal: true

require 'test_helper'

class RockTest < ActiveSupport::TestCase
  test 'Rock::LIST is an array' do
    assert Rock::LIST.is_a?(Array)
  end

  test 'Rock::LIST contains expected values' do
    expected_anchors = %w[
      slate
      limestone
      conglomerate
      gabbro
      gneiss
      granite
      sandstone
      migmatite
      molasses
      quartzite
      serpentinite
      silex
      basalt
      rhyolite
      andesite
      schist
      phonolite
      resin
    ]
    assert_equal expected_anchors.sort, Rock::LIST.sort
  end

  test 'Rock::LIST is frozen' do
    assert Rock::LIST.frozen?
  end

  test 'Rock::LIST has 18 elements' do
    assert_equal 18, Rock::LIST.size
  end
end
