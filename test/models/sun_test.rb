# frozen_string_literal: true

require 'test_helper'

class SunTest < ActiveSupport::TestCase
  test 'Sun::LIST is an array' do
    assert Sun::LIST.is_a?(Array)
  end

  test 'Sun::LIST contains expected values' do
    expected_anchors = %w[
      sunny_all_day
      shady
      sunny_afternoon
      sunny_morning
    ]
    assert_equal expected_anchors.sort, Sun::LIST.sort
  end

  test 'Sun::LIST is frozen' do
    assert Sun::LIST.frozen?
  end

  test 'Sun::LIST has 4 elements' do
    assert_equal 4, Sun::LIST.size
  end
end
