# frozen_string_literal: true

require 'test_helper'

class ContestStageTest < ActiveSupport::TestCase
  setup do
    @contest_stage = contest_stages(:stage_1)
    @contest = contests(:contest_1)
  end

  test 'contest stage is valid' do
    assert @contest_stage.valid?
  end

  test 'contest stage is invalid without climbing_type' do
    @contest_stage.climbing_type = nil
    assert_not @contest_stage.valid?
    assert_includes @contest_stage.errors.keys, :climbing_type
  end

  test 'contest stage is invalid with wrong climbing_type' do
    @contest_stage.climbing_type = 'walking'
    assert_not @contest_stage.valid?
    assert_includes @contest_stage.errors.keys, :climbing_type
  end

  test 'contest stage is invalid with wrong default_ranking_type' do
    @contest_stage.default_ranking_type = 'random_ranking'
    assert_not @contest_stage.valid?
    assert_includes @contest_stage.errors.keys, :default_ranking_type
  end

  test 'set_order sets stage_order on create' do
    new_stage = ContestStage.create(
      contest: @contest,
      climbing_type: Climb::SPORT_CLIMBING,
      name: 'New Stage'
    )
    assert_not_nil new_stage.stage_order
    assert_equal 4, new_stage.stage_order
  end

  test 'summary_to_json returns expected keys' do
    json = @contest_stage.summary_to_json
    assert_equal @contest_stage.id, json[:id]
    assert_equal @contest_stage.name, json[:name]
    assert_includes json.keys, :gym
    assert_includes json.keys, :contest
  end

  test 'detail_to_json returns expected keys including associations' do
    json = @contest_stage.detail_to_json
    assert_equal @contest_stage.id, json[:id]
    assert_includes json.keys, :contest_stage_steps
  end

  test 'normalize_attributes strips and nils description' do
    @contest_stage.description = '  Some description  '
    @contest_stage.valid?
    assert_equal 'Some description', @contest_stage.description

    @contest_stage.description = '   '
    @contest_stage.valid?
    assert_nil @contest_stage.description
  end
end
