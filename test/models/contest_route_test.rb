# frozen_string_literal: true

require 'test_helper'

class ContestRouteTest < ActiveSupport::TestCase
  setup do
    @route = contest_routes(:route_1)
  end

  test 'contest route is valid' do
    assert @route.valid?
  end

  test 'contest route is invalid with negative number' do
    @route.number = -1
    assert_not @route.valid?
  end

  test 'disable! sets disabled_at' do
    assert_nil @route.disabled_at
    @route.disable!
    assert_not_nil @route.reload.disabled_at
  end

  test 'enable! clears disabled_at' do
    @route.update_column(:disabled_at, DateTime.current)
    @route.enable!
    assert_nil @route.reload.disabled_at
  end

  test 'summary_to_json returns expected keys' do
    json = @route.summary_to_json
    assert_equal @route.id, json[:id]
    assert_equal @route.number, json[:number]
    assert_includes json.keys, :contest_route_group_id
    assert_includes json.keys, :ranking_type
  end
end
