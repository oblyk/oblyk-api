# frozen_string_literal: true

require 'test_helper'

class TickListTest < ActiveSupport::TestCase
  setup do
    @tick_list = tick_lists(:one)
  end

  test 'tick list is valid' do
    assert @tick_list.valid?
  end

  test 'tick list belongs to user' do
    assert_equal users(:normal_user), @tick_list.user
  end

  test 'tick list belongs to crag_route' do
    assert_equal crag_routes(:route_one), @tick_list.crag_route
  end

  test 'summary_to_json returns the same as detail_to_json' do
    assert_equal @tick_list.detail_to_json, @tick_list.summary_to_json
  end

  test 'detail_to_json returns the correct format' do
    json = @tick_list.detail_to_json
    assert_equal @tick_list.id, json[:id]
    assert_equal @tick_list.crag_route.id, json[:crag_route][:id]
    assert_equal @tick_list.crag_route.name, json[:crag_route][:name]
    assert_equal @tick_list.created_at, json[:history][:created_at]
    assert_equal @tick_list.updated_at, json[:history][:updated_at]
  end

  test 'tick list is invalid without user' do
    tick_list = TickList.new(crag_route: crag_routes(:route_one))
    assert_not tick_list.valid?
  end

  test 'tick list is invalid without crag_route' do
    tick_list = TickList.new(user: users(:normal_user))
    assert_not tick_list.valid?
  end
end
