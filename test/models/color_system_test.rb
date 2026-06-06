# frozen_string_literal: true

require 'test_helper'

class ColorSystemTest < ActiveSupport::TestCase
  setup do
    @color_system = color_systems(:system_1)
  end

  test 'color system is valid' do
    assert @color_system.valid?
  end

  test 'color system is invalid without colors_mark' do
    @color_system.colors_mark = nil
    assert_not @color_system.valid?
    assert_includes @color_system.errors.keys, :colors_mark
  end

  test 'color system is invalid with duplicate colors_mark' do
    duplicate_system = ColorSystem.new(colors_mark: @color_system.colors_mark)
    assert_not duplicate_system.valid?
    assert_includes duplicate_system.errors.keys, :colors_mark
  end

  test 'init_line_form_colors adds lines to color system' do
    system = ColorSystem.new(colors_mark: 'test_mark')
    colors = ['#123456', '#654321']
    system.init_line_form_colors(colors)
    
    assert_equal 2, system.color_system_lines.size
    assert_equal '#123456', system.color_system_lines.first.hex_color
    assert_equal 1, system.color_system_lines.first.order
    assert_equal '#654321', system.color_system_lines.last.hex_color
    assert_equal 2, system.color_system_lines.last.order
  end

  test 'init_line_from_gym_level adds lines from gym level' do
    system = ColorSystem.new(colors_mark: 'gym_mark')
    gym_level = OpenStruct.new(levels: [
      { color: '#AABBCC', order: 1 },
      { color: '#DDEEFF', order: 2 }
    ])
    system.init_line_from_gym_level(gym_level)

    assert_equal 2, system.color_system_lines.size
    assert_equal '#AABBCC', system.color_system_lines.first.hex_color
    assert_equal 1, system.color_system_lines.first.order
    assert_equal '#DDEEFF', system.color_system_lines.last.hex_color
    assert_equal 2, system.color_system_lines.last.order
  end

  test 'create_from_level creates or finds a color system' do
    gym_level = OpenStruct.new(
      colors_system_mark: 'new_gym_mark',
      levels: [{ color: '#112233', order: 1 }]
    )

    assert_difference 'ColorSystem.count', 1 do
      ColorSystem.create_from_level(gym_level)
    end

    # Should find existing one if mark is same
    assert_no_difference 'ColorSystem.count' do
      ColorSystem.create_from_level(gym_level)
    end
  end

  test 'summary_to_json returns expected keys' do
    json = @color_system.summary_to_json
    assert_equal @color_system.id, json[:id]
    assert_equal @color_system.colors_mark, json[:colors_mark]
    assert_equal @color_system.color_system_lines.count, json[:color_system_lines].size
  end

  test 'detail_to_json returns expected keys' do
    json = @color_system.detail_to_json
    assert_equal @color_system.id, json[:id]
    assert_equal @color_system.colors_mark, json[:colors_mark]
    assert_equal @color_system.color_system_lines.count, json[:color_system_lines].size
  end
end
