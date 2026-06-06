# frozen_string_literal: true

require 'test_helper'

class ContestTeamTest < ActiveSupport::TestCase
  setup do
    @team = contest_teams(:team_1)
    @contest = contests(:contest_ongoing)
  end

  test 'contest team is valid' do
    assert @team.valid?
  end

  test 'contest team is invalid without name' do
    @team.name = nil
    assert_not @team.valid?
    assert_includes @team.errors.keys, :name
  end

  test 'contest team name is unique within a contest' do
    duplicate_team = ContestTeam.new(name: @team.name, contest: @contest)
    assert_not duplicate_team.valid?
    assert_includes duplicate_team.errors.keys, :name
  end

  test 'strip_whitespace removes leading and trailing spaces from name' do
    @team.name = '  Team name with spaces  '
    @team.valid?
    assert_equal 'Team name with spaces', @team.name
  end

  test 'summary_to_json returns expected keys' do
    json = @team.summary_to_json
    assert_equal @team.id, json[:id]
    assert_equal @team.name, json[:name]
    assert_equal @team.contest_id, json[:contest_id]
    assert_includes json.keys, :number_of_participants
    assert_includes json.keys, :remaining_places
    assert_includes json.keys, :detail_name
  end

  test 'detail_to_json returns expected keys' do
    json = @team.detail_to_json
    assert_equal @team.id, json[:id]
    assert_includes json.keys, :contest_participants
    assert_includes json.keys, :history
  end

  test 'detail_name returns formatted string' do
    assert_equal 'Team 1 (2/2)', @team.detail_name
  end

  test 'number_of_participants returns correct count' do
    assert_equal 2, @team.number_of_participants
  end

  test 'remaining_places returns correct value' do
    assert_equal 0, @team.remaining_places

    @team.contest_participants.first.update_column(:contest_team_id, nil)
    assert_equal 1, @team.reload.remaining_places
  end

  test 'un_team_participants sets participant contest_team_id to nil on destroy' do
    participants = @team.contest_participants.to_a
    assert_not_empty participants

    @team.destroy

    participants.each do |participant|
      assert_nil participant.reload.contest_team_id
    end
  end
end
