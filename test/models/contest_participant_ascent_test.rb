# frozen_string_literal: true

require 'test_helper'

class ContestParticipantAscentTest < ActiveSupport::TestCase
  setup do
    @ascent = contest_participant_ascents(:ascent_1)
  end

  test 'contest_participant_ascent is valid' do
    assert @ascent.valid?
  end

  test 'registered_at is set before save' do
    new_ascent = ContestParticipantAscent.new(
      contest_participant: contest_participants(:participant_1),
      contest_route: contest_routes(:route_2),
      realised: true
    )
    assert_nil new_ascent.registered_at
    new_ascent.save
    assert_not_nil new_ascent.registered_at
  end

  test 'normalize_attributes sets blank values to nil' do
    @ascent.zone_1_attempt = ''
    @ascent.zone_2_attempt = ''
    @ascent.top_attempt = ''
    @ascent.hold_number = ''
    @ascent.hold_number_plus = ''
    @ascent.valid?

    assert_nil @ascent.zone_1_attempt
    assert_nil @ascent.zone_2_attempt
    assert_nil @ascent.top_attempt
    assert_nil @ascent.hold_number
    assert_nil @ascent.hold_number_plus
  end

  test 'summary_to_json returns expected keys' do
    json = @ascent.summary_to_json
    assert_equal @ascent.id, json[:id]
    assert_equal @ascent.contest_participant_id, json[:contest_participant_id]
    assert_equal @ascent.contest_route_id, json[:contest_route_id]
    assert_includes json.keys, :registered_at
    assert_includes json.keys, :realised
  end

  test 'detail_to_json returns expected keys including associations' do
    json = @ascent.detail_to_json
    assert_equal @ascent.id, json[:id]
    assert_includes json.keys, :contest_participant
  end

  test 'delete_results_cache is called after update' do
    mock_contest = Minitest::Mock.new
    mock_contest.expect :call, true

    @ascent.contest.stub :delete_results_cache, mock_contest do
      @ascent.update(realised: false)
    end
    mock_contest.verify
  end

  test 'delete_results_cache is called after destroy' do
    mock_contest = Minitest::Mock.new
    mock_contest.expect :call, true

    @ascent.contest.stub :delete_results_cache, mock_contest do
      @ascent.destroy
    end
    mock_contest.verify
  end
end
