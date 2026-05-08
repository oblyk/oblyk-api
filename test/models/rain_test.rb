# frozen_string_literal: true

require 'test_helper'

class RainTest < ActiveSupport::TestCase
  test 'Rain::LIST is an array' do
    assert Rain::LIST.is_a?(Array)
  end

  test 'Rain::LIST contains expected values' do
    expected_anchors = %w[
      protected
      exposed
    ]
    assert_equal expected_anchors.sort, Rain::LIST.sort
  end

  test 'Rain::LIST is frozen' do
    assert Rain::LIST.frozen?
  end

  test 'Rain::LIST has 2 elements' do
    assert_equal 2, Rain::LIST.size
  end
end
