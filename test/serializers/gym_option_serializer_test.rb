# frozen_string_literal: true

require 'test_helper'

class GymOptionSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_option = gym_options(:contest_option)
    @serializer = GymOptionSerializer.new(@gym_option)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_option.id, attributes['id']
    assert_equal @gym_option.option_type, attributes['option_type']
    assert_equal @gym_option.start_date.as_json, attributes['start_date']
    assert_equal @gym_option.remaining_unit, attributes['remaining_unit']
    assert_equal @gym_option.unlimited_unit, attributes['unlimited_unit']
    assert_equal @gym_option.activated?, attributes['activated']
    assert_equal @gym_option.credited?, attributes['credited']
    assert_equal @gym_option.usable?, attributes['usable']
  end
end
