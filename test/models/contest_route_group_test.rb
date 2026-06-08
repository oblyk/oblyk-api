# frozen_string_literal: true

require 'test_helper'

class ContestRouteGroupTest < ActiveSupport::TestCase
  setup do
    @route_group = contest_route_groups(:route_group_1)
    @step = contest_stage_steps(:step_1_stage_1)
    @category = contest_categories(:category_u18)
  end

  test 'contest route group is valid' do
    assert @route_group.valid?
  end

  test 'contest route group is invalid without categories' do
    @route_group.contest_categories = []
    assert_not @route_group.valid?
    assert_includes @route_group.errors.messages[:contest_categories], 'you_must_choose_one'
  end

  test 'contest route group is invalid with wrong genre_type' do
    @route_group.genre_type = 'other'
    assert_not @route_group.valid?
  end

  test 'name returns expected string' do
    assert_equal 'Groupe 1 U16 unisex', @route_group.name
  end

  test 'normalize_attributes sets dates if contest is one day and not waveable' do
    contest = @route_group.contest
    contest.update(start_date: Date.current, end_date: Date.current)

    @route_group.start_date = nil
    @route_group.valid?

    assert_equal contest.start_date, @route_group.start_date
    assert_equal contest.end_date, @route_group.end_date
  end

  test 'normalize_attributes clears times and dates if waveable' do
    @route_group.waveable = true
    @route_group.start_time = Time.current
    @route_group.start_date = Date.current

    @route_group.valid?

    assert_nil @route_group.start_time
    assert_nil @route_group.start_date
  end

  test 'validate_categories prevents same category and genre in same step' do
    new_group = ContestRouteGroup.new(
      contest_stage_step: @step,
      genre_type: @route_group.genre_type,
      waveable: false,
      contest_categories: @route_group.contest_categories
    )

    assert_not new_group.valid?
    assert_includes new_group.errors.messages[:base], 'category_is_taken_in_this_step'
  end

  test 'summary_to_json returns expected keys' do
    json = @route_group.summary_to_json
    assert_equal @route_group.id, json[:id]
    assert_equal @route_group.name, json[:name]
    assert_includes json.keys, :contest_categories
    assert_includes json.keys, :contest_routes
  end

  test 'import_from_spaces creates contest routes from gym routes' do
    space = gym_spaces(:my_gym_boulder_space)
    initial_count = @route_group.contest_routes.count

    gym_routes_count = GymRoute.joins(:gym_sector).where(gym_sectors: { gym_space_id: space.id }).mounted.count

    assert_difference 'ContestRoute.count', gym_routes_count do
      @route_group.import_from_spaces([space.id])
    end

    assert_equal initial_count + gym_routes_count, @route_group.contest_routes.count
  end

  test 'create_participant_step calls create_participant_step on contest participants' do
    assert_respond_to @route_group, :create_participant_step
  end
end
