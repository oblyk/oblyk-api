# frozen_string_literal: true

require 'test_helper'

class GymSpaceGroupTest < ActiveSupport::TestCase
  setup do
    @gym_space_group = gym_space_groups(:gym_space_group_1)
  end

  test 'gym_space_group is valid' do
    assert @gym_space_group.valid?
  end

  test 'gym_space_group is invalid without name' do
    @gym_space_group.name = nil
    assert_not @gym_space_group.valid?
  end

  test 'summary_to_json returns correct keys' do
    summary = @gym_space_group.summary_to_json
    assert_equal @gym_space_group.id, summary[:id]
    assert_equal @gym_space_group.name, summary[:name]
    assert_includes summary.keys, :gym_space_ids
    assert_includes summary.keys, :gym
  end

  test 'detail_to_json returns correct keys' do
    detail = @gym_space_group.detail_to_json
    assert_equal @gym_space_group.id, detail[:id]
    assert_includes detail.keys, :history
  end

  test 'destroying a gym_space_group unsets gym_space_group_id on its gym_spaces' do
    gym_space = gym_spaces(:my_gym_boulder_space)
    assert_equal @gym_space_group.id, gym_space.gym_space_group_id
    
    @gym_space_group.destroy
    
    gym_space.reload
    assert_nil gym_space.gym_space_group_id
    assert_not GymSpaceGroup.exists?(@gym_space_group.id)
  end
end
