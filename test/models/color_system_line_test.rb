# frozen_string_literal: true

require 'test_helper'

class ColorSystemLineTest < ActiveSupport::TestCase
  setup do
    @line = color_system_lines(:line_1_1)
  end

  test 'color system line is valid' do
    assert @line.valid?
  end

  test 'summary_to_json returns expected keys' do
    json = @line.summary_to_json
    assert_equal @line.id, json[:id]
    assert_equal @line.hex_color, json[:hex_color]
    assert_equal @line.order, json[:order]
  end

  test 'detail_to_json returns expected keys' do
    json = @line.detail_to_json
    assert_equal @line.id, json[:id]
    assert_equal @line.hex_color, json[:hex_color]
    assert_equal @line.order, json[:order]
  end

  test 'default scope orders by order' do
    lines = ColorSystemLine.where(color_system: color_systems(:system_1))
    assert_equal 1, lines.first.order
    assert_equal 2, lines.second.order
    assert_equal 3, lines.third.order
  end
end
