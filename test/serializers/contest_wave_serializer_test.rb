# frozen_string_literal: true

require 'test_helper'

class ContestWaveSerializerTest < ActiveSupport::TestCase
  setup do
    @wave = contest_waves(:wave_1)
    @serializer = ContestWaveSerializer.new(@wave)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @wave.id, attributes['id']
    assert_equal @wave.name, attributes['name']
    assert_equal @wave.capacity, attributes['capacity']
    assert_equal @wave.contest_id, attributes['contest_id']
    assert_equal @wave.created_at.as_json, attributes['history']['created_at']
  end
end
