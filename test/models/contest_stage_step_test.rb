# frozen_string_literal: true

require 'test_helper'

class ContestStageStepTest < ActiveSupport::TestCase
  setup do
    @contest_stage_step = contest_stage_steps(:step_1_stage_1)
    @contest_stage = contest_stages(:stage_1)
  end

  test 'contest stage step is valid' do
    assert @contest_stage_step.valid?
  end

  test 'contest stage step is invalid without name' do
    @contest_stage_step.name = nil
    assert_not @contest_stage_step.valid?
    assert_includes @contest_stage_step.errors.keys, :name
  end

  test 'contest stage step is invalid with wrong ranking_type' do
    @contest_stage_step.ranking_type = 'random_ranking'
    assert_not @contest_stage_step.valid?
    assert_includes @contest_stage_step.errors.keys, :ranking_type
  end

  test 'contest stage step is invalid with non-positive ascents_limit' do
    @contest_stage_step.ascents_limit = 0
    assert_not @contest_stage_step.valid?
    assert_includes @contest_stage_step.errors.keys, :ascents_limit

    @contest_stage_step.ascents_limit = -1
    assert_not @contest_stage_step.valid?
    assert_includes @contest_stage_step.errors.keys, :ascents_limit
  end

  test 'set_order sets step_order on create' do
    new_step = ContestStageStep.create(
      contest_stage: @contest_stage,
      name: 'New Step',
      ranking_type: ContestService::Constant::DIVISION
    )
    assert_not_nil new_step.step_order
    assert_equal 3, new_step.step_order
  end

  test 'summary_to_json returns expected keys' do
    json = @contest_stage_step.summary_to_json
    assert_equal @contest_stage_step.id, json[:id]
    assert_equal @contest_stage_step.name, json[:name]
    assert_includes json.keys, :gym
    assert_includes json.keys, :contest
    assert_includes json.keys, :contest_stage
  end

  test 'detail_to_json returns expected keys including associations' do
    json = @contest_stage_step.detail_to_json
    assert_equal @contest_stage_step.id, json[:id]
    assert_includes json.keys, :contest_routes
  end
end
