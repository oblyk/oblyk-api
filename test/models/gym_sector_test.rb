# frozen_string_literal: true

require 'test_helper'

class GymSectorTest < ActiveSupport::TestCase
  setup do
    @gym_sector = gym_sectors(:my_gym_sector)
  end

  test 'gym_sector is valid' do
    assert @gym_sector.valid?
  end

  test 'gym_sector is invalid without name' do
    @gym_sector.name = nil
    assert_not @gym_sector.valid?
  end

  test 'gym_sector is invalid without height' do
    @gym_sector.height = nil
    assert_not @gym_sector.valid?
  end

  test 'gym_sector is invalid with incorrect climbing_type' do
    @gym_sector.climbing_type = 'invalid_type'
    assert_not @gym_sector.valid?
  end

  test 'gym_sector app_path returns correct path' do
    gym = @gym_sector.gym_space.gym
    gym_space = @gym_sector.gym_space
    expected_path = "/gyms/#{gym.id}/#{gym.slug_name}/spaces/#{gym_space.id}/#{gym_space.slug_name}?sector=#{@gym_sector.id}"
    assert_equal expected_path, @gym_sector.app_path
  end

  test 'gym_sector summary_to_json returns correct keys' do
    summary = @gym_sector.summary_to_json
    assert_equal @gym_sector.id, summary[:id]
    assert_equal @gym_sector.name, summary[:name]
    assert_includes summary.keys, :gym
    assert_includes summary.keys, :gym_space
  end

  test 'anchor_ranges returns correct array' do
    @gym_sector.min_anchor_number = 1
    @gym_sector.max_anchor_number = 5
    assert_equal [1, 2, 3, 4, 5], @gym_sector.anchor_ranges

    @gym_sector.min_anchor_number = 5
    @gym_sector.max_anchor_number = 1
    assert_equal [1, 2, 3, 4, 5], @gym_sector.anchor_ranges
  end

  test 'anchor_ranges returns empty array if one is blank' do
    @gym_sector.min_anchor_number = 1
    @gym_sector.max_anchor_number = nil
    assert_equal [], @gym_sector.anchor_ranges
  end
end
