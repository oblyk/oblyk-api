# frozen_string_literal: true

require 'test_helper'

class ContestWaveTest < ActiveSupport::TestCase
  setup do
    @wave = contest_waves(:wave_1)
    @contest = contests(:contest_1)
  end

  test 'contest wave is valid' do
    assert @wave.valid?
  end

  test 'contest wave is invalid without name' do
    @wave.name = nil
    assert_not @wave.valid?
    assert_includes @wave.errors.attribute_names, :name
  end

  test 'normalize_attributes sets capacity to nil if zero or blank' do
    @wave.capacity = 0
    @wave.valid?
    assert_nil @wave.capacity

    @wave.capacity = ""
    @wave.valid?
    assert_nil @wave.capacity
  end

  test 'summary_to_json returns expected keys' do
    json = @wave.summary_to_json
    assert_equal @wave.id, json[:id]
    assert_equal @wave.name, json[:name]
    assert_equal @wave.contest_id, json[:contest_id]
    assert_includes json.keys, :capacity
    assert_includes json.keys, :contest_participants_count
  end

  test 'detail_to_json returns expected keys' do
    json = @wave.detail_to_json
    assert_equal @wave.id, json[:id]
    assert_includes json.keys, :history
  end

  test 'default scope orders by name' do
    assert_equal ['Wave 1', 'Wave 2'], ContestWave.all.pluck(:name)
  end

  test 'delete_caches is called after save' do
    assert @wave.save
  end
end
