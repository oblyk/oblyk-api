# frozen_string_literal: true

require 'test_helper'

class ContestSerializerTest < ActiveSupport::TestCase
  setup do
    @contest = contests(:contest_1)
    @serializer = ContestSerializer.new(@contest)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @contest.id, attributes['id']
    assert_equal @contest.name, attributes['name']

    if @contest.slug_name.nil?
      assert_nil attributes['slug_name']
    else
      assert_equal @contest.slug_name, attributes['slug_name']
    end

    if @contest.description.nil?
      assert_nil attributes['description']
    else
      assert_equal @contest.description, attributes['description']
    end

    assert_equal @contest.gym_id, attributes['gym_id']
    assert_equal @contest.start_date.to_s, attributes['start_date']
    assert_equal @contest.end_date.to_s, attributes['end_date']
    assert_equal @contest.subscription_start_date.to_s, attributes['subscription_start_date']
    assert_equal @contest.subscription_end_date.to_s, attributes['subscription_end_date']

    if @contest.combined_ranking_type.nil?
      assert_nil attributes['combined_ranking_type']
    else
      assert_equal @contest.combined_ranking_type, attributes['combined_ranking_type']
    end

    assert_equal @contest.draft, attributes['draft']
    assert_equal @contest.private, attributes['private']

    if @contest.total_capacity.nil?
      assert_nil attributes['total_capacity']
    else
      assert_equal @contest.total_capacity, attributes['total_capacity']
    end

    assert_equal @contest.categorization_type, attributes['categorization_type']
    assert_equal @contest.team_contest, attributes['team_contest']
    assert_equal @contest.one_day_event?, attributes['one_day_event']
    assert_equal @contest.finished?, attributes['finished']
    assert_equal @contest.ongoing?, attributes['ongoing']
    assert_equal @contest.coming?, attributes['coming']
    assert_equal @contest.subscription_opened?, attributes['subscription_opened']
    assert_equal @contest.created_at.as_json, attributes['history']['created_at']
  end

  test 'It includes associations if specified' do
    serializer = ContestSerializer.new(@contest, { include: [:gym, :contest_categories, :contest_stages] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'gym' }
    assert serialization['included'].any? { |inc| inc['type'] == 'contest_category' }
    assert serialization['included'].any? { |inc| inc['type'] == 'contest_stage' }
  end
end
