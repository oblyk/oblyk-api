# frozen_string_literal: true

require 'test_helper'

class FfmeContestSerializerTest < ActiveSupport::TestCase
  setup do
    @ffme_contest = ffme_contests(:ffme_contest_1)
    @serializer = FfmeContestSerializer.new(@ffme_contest)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @ffme_contest.id, attributes['id']
    assert_equal @ffme_contest.contest_id, attributes['contest_id']
    assert_equal @ffme_contest.status, attributes['status']
    assert_equal @ffme_contest.contest_type, attributes['contest_type']
    assert_equal @ffme_contest.name, attributes['name']
    if @ffme_contest.description.nil?
      assert_nil attributes['description']
    else
      assert_equal @ffme_contest.description, attributes['description']
    end
    assert_equal @ffme_contest.start_date.as_json, attributes['start_date']
    assert_equal @ffme_contest.end_date.as_json, attributes['end_date']
    assert_equal @ffme_contest.min_send_date.as_json, attributes['min_send_date']
    assert_equal @ffme_contest.max_send_date.as_json, attributes['max_send_date']
  end

  test 'It contains the sendable attribute' do
    attributes = @serialization['data']['attributes']
    assert_equal @ffme_contest.sendable?, attributes['sendable']
  end

  test 'It contains the history' do
    attributes = @serialization['data']['attributes']
    assert_equal @ffme_contest.created_at.as_json, attributes['history']['created_at']
    assert_equal @ffme_contest.updated_at.as_json, attributes['history']['updated_at']
  end
end
