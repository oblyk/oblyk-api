# frozen_string_literal: true

require 'test_helper'

class ColorSystemSerializerTest < ActiveSupport::TestCase
  setup do
    @color_system = color_systems(:system_1)
    @serializer = ColorSystemSerializer.new(@color_system)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @color_system.id, attributes['id']
    assert_equal @color_system.colors_mark, attributes['colors_mark']
  end

  test 'It includes color_system_lines if specified' do
    serializer = ColorSystemSerializer.new(@color_system, { include: [:color_system_lines] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'color_system_line' }
  end
end
