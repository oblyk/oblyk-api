# frozen_string_literal: true

require 'test_helper'

class ContestTimeBlockTest < ActiveSupport::TestCase
  setup do
    @time_block = contest_time_blocks(:time_block_1)
    @wave = contest_waves(:wave_1)
    @route_group = contest_route_groups(:route_group_1)
  end

  test 'time block is valid' do
    assert @time_block.valid?
  end

  test 'time block is invalid without start_time' do
    @time_block.start_time = nil
    assert_not @time_block.valid?
    assert_includes @time_block.errors.keys, :start_time
  end

  test 'time block is invalid without end_time' do
    @time_block.end_time = nil
    assert_not @time_block.valid?
    assert_includes @time_block.errors.keys, :end_time
  end

  test 'summary_to_json returns expected keys' do
    json = @time_block.summary_to_json
    assert_equal @time_block.id, json[:id]
    assert_equal @time_block.name, json[:name]
    assert_equal @time_block.start_time, json[:start_time]
    assert_equal @time_block.end_time, json[:end_time]
    assert_equal @time_block.contest_wave_id, json[:contest_wave_id]
  end

  test 'normalize_attributes sets dates from contest if one day event' do
    contest = @time_block.contest
    new_date = DateTime.current + 15.days
    contest.update(
      start_date: new_date.to_date,
      end_date: new_date.to_date
    )
    assert contest.one_day_event?

    new_time_block = ContestTimeBlock.new(
      contest_wave: @wave,
      contest_route_group: @route_group,
      start_time: new_date.beginning_of_day + 10.hours,
      end_time: new_date.beginning_of_day + 12.hours
    )
    new_time_block.valid?
    assert_equal contest.start_date, new_time_block.start_date
    assert_equal contest.end_date, new_time_block.end_date
  end

  test 'delete_caches is called after save' do
    assert @time_block.save
  end
end
