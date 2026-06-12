# frozen_string_literal: true

require 'test_helper'

class ContestStageSerializerTest < ActiveSupport::TestCase
  setup do
    @stage = contest_stages(:stage_1)
    @serializer = ContestStageSerializer.new(@stage)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @stage.id, attributes['id']
    assert_equal @stage.climbing_type, attributes['climbing_type']
    assert_equal @stage.name, attributes['name']
    assert_equal @stage.stage_order, attributes['stage_order']
    assert_equal @stage.default_ranking_type, attributes['default_ranking_type']
    assert_equal @stage.contest_id, attributes['contest_id']
    assert_equal @stage.created_at.as_json, attributes['history']['created_at']
  end

  test 'It includes contest if specified' do
    serializer = ContestStageSerializer.new(@stage, { include: [:contest] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'contest' }
  end
end
