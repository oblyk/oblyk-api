# frozen_string_literal: true

require 'test_helper'

class ContestTest < ActiveSupport::TestCase
  setup do
    @contest = contests(:contest_1)
    @gym = gyms(:my_gym)
  end

  test 'contest is valid' do
    assert @contest.valid?
  end

  test 'contest is invalid without name' do
    @contest.name = nil
    assert_not @contest.valid?
    assert_includes @contest.errors.attribute_names, :name
  end

  test 'contest is invalid with end_date before start_date' do
    @contest.end_date = @contest.start_date - 1.day
    assert_not @contest.valid?
    assert_includes @contest.errors.attribute_names, :end_date
  end

  test 'contest is invalid with subscription_end_date before subscription_start_date' do
    @contest.subscription_end_date = @contest.subscription_start_date - 1.day
    assert_not @contest.valid?
    assert_includes @contest.errors.attribute_names, :subscription_end_date
  end

  test 'contest is invalid with end_date before subscription_end_date' do
    @contest.end_date = @contest.subscription_end_date - 1.day
    assert_not @contest.valid?
    assert_includes @contest.errors.attribute_names, :subscription_end_date
  end

  test 'remaining_places returns expected value' do
    @contest.total_capacity = 100
    assert_equal 98, @contest.remaining_places

    @contest.total_capacity = nil
    assert_nil @contest.remaining_places
  end

  test 'one_day_event? returns true if start and end date are same' do
    @contest.start_date = Date.current
    @contest.end_date = Date.current
    assert @contest.one_day_event?

    @contest.end_date = Date.current + 1.day
    assert_not @contest.one_day_event?
  end

  test 'subscription_opened? returns true only when current date is within range' do
    @contest.subscription_start_date = Date.current - 1.day
    @contest.subscription_end_date = Date.current + 1.day
    assert @contest.subscription_opened?

    @contest.subscription_start_date = Date.current + 1.day
    assert_not @contest.subscription_opened?
  end

  test 'finished? returns true if end_date is in past' do
    contest = contests(:contest_finished)
    assert contest.finished?

    assert_not @contest.finished?
  end

  test 'ongoing? returns true if current date is between start and end date' do
    contest = contests(:contest_ongoing)
    assert contest.ongoing?

    assert_not @contest.ongoing?
  end

  test 'coming? returns true if start date is in future' do
    assert @contest.coming?

    contest = contests(:contest_finished)
    assert_not contest.coming?
  end

  test 'upcoming scope returns only non-draft, non-private and not finished contests' do
    upcoming = Contest.upcoming
    assert_includes upcoming, contests(:contest_1)
    assert_includes upcoming, contests(:contest_ongoing)
    assert_not_includes upcoming, contests(:contest_finished)

    @contest.update_column(:draft, true)
    assert_not_includes Contest.upcoming, @contest
  end

  test 'summary_to_json returns expected keys' do
    json = @contest.summary_to_json
    assert_equal @contest.id, json[:id]
    assert_equal @contest.name, json[:name]
    assert_includes json.keys, :remaining_places
    assert_includes json.keys, :ongoing
    assert_includes json.keys, :finished
  end

  test 'detail_to_json returns expected keys including associations' do
    json = @contest.detail_to_json
    assert_equal @contest.id, json[:id]
    assert_includes json.keys, :gym
    assert_includes json.keys, :contest_categories
    assert_includes json.keys, :contest_stages
  end

  test 'normalize_attributes sets default combined_ranking_type' do
    contest = Contest.new(
      name: 'New Contest',
      gym: @gym,
      start_date: Date.current,
      end_date: Date.current,
      subscription_start_date: Date.current,
      subscription_end_date: Date.current,
      categorization_type: 'custom'
    )
    contest.valid?
    assert_equal ContestService::Constant::COMBINED_RANKING_DECREMENT_POINTS, contest.combined_ranking_type
  end

  test 'set_draft_mode sets draft to true on create' do
    contest = Contest.create(
      name: 'New Contest',
      gym: @gym,
      start_date: Date.current,
      end_date: Date.current,
      subscription_start_date: Date.current,
      subscription_end_date: Date.current,
      categorization_type: 'custom'
    )
    assert contest.draft
  end

  test 'create_u_age creates categories when categorization_type is official_under_age' do
    contest = Contest.new(
      name: 'Under Age Contest',
      gym: @gym,
      start_date: Date.current,
      end_date: Date.current,
      subscription_start_date: Date.current,
      subscription_end_date: Date.current,
      categorization_type: 'official_under_age'
    )
    assert_difference 'ContestCategory.count', ContestCategory::OBLIGATION_LIST.size - 1 do
      contest.save
    end
    assert_equal ContestCategory::OBLIGATION_LIST.size - 1, contest.contest_categories.size
  end
end
