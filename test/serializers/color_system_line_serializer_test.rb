# frozen_string_literal: true

require 'test_helper'

class ColorSystemLineSerializerTest < ActiveSupport::TestCase
  setup do
    @color_system_line = color_system_lines(:line_1_1)
    @serializer = ColorSystemLineSerializer.new(@color_system_line)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @color_system_line.id, attributes['id']
    assert_equal @color_system_line.hex_color, attributes['hex_color']
    assert_equal @color_system_line.order, attributes['order']
  end

  test 'It includes color_system if specified' do
    serializer = ColorSystemLineSerializer.new(@color_system_line, { include: [:color_system] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'color_system' }
  end
end
