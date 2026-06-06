# frozen_string_literal: true

require 'test_helper'

class ContestParticipantStepTest < ActiveSupport::TestCase
  setup do
    @participant_step = contest_participant_steps(:participant_step_1)
    @participant = contest_participants(:participant_1)
    @step = contest_stage_steps(:step_1_stage_1)
  end

  test 'participant step is valid' do
    assert @participant_step.valid?
  end

  test 'belongs to contest_participant' do
    assert_equal @participant, @participant_step.contest_participant
  end

  test 'belongs to contest_stage_step' do
    assert_equal @step, @participant_step.contest_stage_step
  end

  test 'has one contest_category through contest_participant' do
    assert_equal @participant.contest_category, @participant_step.contest_category
  end

  test 'has one contest through contest_category' do
    assert_equal @participant.contest_category.contest, @participant_step.contest
  end

  test 'delete_caches is called after save' do
    assert @participant_step.save
  end
end
