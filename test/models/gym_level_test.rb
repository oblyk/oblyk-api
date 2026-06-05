# frozen_string_literal: true

require 'test_helper'

class GymLevelTest < ActiveSupport::TestCase
  setup do
    @gym_level = gym_levels(:one)
  end

  test 'valid gym level' do
    assert @gym_level.valid?
  end

  test 'invalid without climbing_type' do
    @gym_level.climbing_type = nil
    assert_not @gym_level.valid?
  end

  test 'invalid without level_representation' do
    @gym_level.level_representation = nil
    assert_not @gym_level.valid?
  end

  test 'invalid with wrong climbing_type' do
    @gym_level.climbing_type = 'invalid'
    assert_not @gym_level.valid?
  end

  test 'invalid with wrong level_representation' do
    @gym_level.level_representation = 'invalid'
    assert_not @gym_level.valid?
  end

  test 'uniqueness of climbing_type per gym' do
    duplicate_gym_level = @gym_level.dup
    assert_not duplicate_gym_level.valid?
  end

  test 'normalize_sub_level on sub_level_enabled false' do
    @gym_level.sub_level_enabled = false
    @gym_level.sub_level_max = 3
    @gym_level.save
    assert_nil @gym_level.sub_level_max
  end

  test 'normalize_sub_level on sub_level_enabled true and high value' do
    @gym_level.sub_level_enabled = true
    @gym_level.sub_level_max = 10
    @gym_level.save
    assert_equal 5, @gym_level.sub_level_max
  end

  test 'normalize_sub_level on sub_level_enabled true and low value' do
    @gym_level.sub_level_enabled = true
    @gym_level.sub_level_max = 0
    @gym_level.save
    assert_equal 1, @gym_level.sub_level_max
  end

  test 'colors_system_mark returns concatenated colors' do
    @gym_level.levels = [{ 'color' => '#ff0000' }, { 'color' => '#00ff00' }]
    assert_equal '#ff0000#00ff00', @gym_level.colors_system_mark
  end

  test 'summary_to_json returns expected keys' do
    json = @gym_level.summary_to_json
    assert_equal @gym_level.climbing_type, json[:climbing_type]
    assert_equal @gym_level.enabled, json[:enabled]
    assert_nil json[:grade_system]
    assert_equal @gym_level.level_representation, json[:level_representation]
    assert_equal @gym_level.sub_level_enabled, json[:sub_level_enabled]
    assert_nil json[:sub_level_max]
    assert_equal @gym_level.levels, json[:levels]
    assert_equal @gym_level.gym_id, json[:gym_id]
  end

  test 'detail_to_json returns expected keys' do
    json = @gym_level.detail_to_json
    assert json.key?(:gym)
    assert_equal @gym_level.gym.id, json[:gym][:id]
  end
end
