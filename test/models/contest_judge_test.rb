# frozen_string_literal: true

require 'test_helper'

class ContestJudgeTest < ActiveSupport::TestCase
  setup do
    @judge = contest_judges(:judge_1)
    @contest = contests(:contest_1)
  end

  test 'contest judge is valid' do
    assert @judge.valid?
  end

  test 'contest judge is invalid without name' do
    @judge.name = nil
    assert_not @judge.valid?
    assert_includes @judge.errors.keys, :name
  end

  test 'contest judge is invalid without code' do
    @judge.code = nil
    assert_not @judge.valid?
    assert_includes @judge.errors.keys, :code
  end

  test 'set_uuid is called before validation' do
    new_judge = ContestJudge.new(name: 'New Judge', code: 'NEW', contest: @contest)
    assert_nil new_judge.uuid
    new_judge.valid?
    assert_not_nil new_judge.uuid
  end

  test 'summary_to_json returns expected keys' do
    json = @judge.summary_to_json
    assert_equal @judge.id, json[:id]
    assert_equal @judge.name, json[:name]
    assert_equal @judge.code, json[:code]
    assert_equal @judge.uuid, json[:uuid]
    assert_equal @judge.contest_id, json[:contest_id]
    assert_kind_of Array, json[:contest_routes]
  end

  test 'detail_to_json returns expected keys including routes_table' do
    json = @judge.detail_to_json
    assert_equal @judge.id, json[:id]
    assert_kind_of Array, json[:routes_table]
    assert_not_empty json[:routes_table]
    
    route_data = json[:routes_table].first
    assert_includes route_data.keys, :contest_stage
    assert_includes route_data.keys, :contest_stage_step
    assert_includes route_data.keys, :contest_route_group
    assert_includes route_data.keys, :contest_categories
    
    assert_includes json.keys, :history
    assert_includes json[:history].keys, :created_at
    assert_includes json[:history].keys, :updated_at
  end
end
