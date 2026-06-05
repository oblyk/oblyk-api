# frozen_string_literal: true

require 'test_helper'

class GymOpeningSheetTest < ActiveSupport::TestCase
  setup do
    @sheet = gym_opening_sheets(:sheet_one)
    @gym = gyms(:my_gym)
  end

  test 'gym_opening_sheet is valid' do
    assert @sheet.valid?
  end

  test 'gym_opening_sheet is invalid without title or number_of_columns' do
    @sheet.title = nil
    assert_not @sheet.valid?
    @sheet.title = 'Title'
    @sheet.number_of_columns = nil
    assert_not @sheet.valid?
  end

  test 'summary_to_json returns expected structure' do
    json = @sheet.summary_to_json
    assert_equal @sheet.id, json[:id]
    assert_equal @sheet.title, json[:title]
    assert_equal @sheet.gym_id, json[:gym_id]
  end

  test 'build_row_json builds expected structure' do
    # Note: GymRoute.mounted is used in build_row_json
    # mounted? is dismounted_at.nil? && archived_at.nil?
    
    @sheet.build_row_json
    assert_not_nil @sheet.row_json
    assert @sheet.row_json.is_a?(Array)
    
    assert @sheet.row_json.size >= 1, "Should have at least one row in row_json"
    
    first_row = @sheet.row_json.first.with_indifferent_access
    assert_not_nil first_row[:sector], "Row should have a sector"
    assert_not_nil first_row[:routes], "Row should have routes"
    
    # number_of_columns * 3 (open, to_open, opened)
    assert_equal @sheet.number_of_columns * 3, first_row[:routes].size
  end

  test 'build_row_json with gym_space_id filter' do
    @sheet.gym_space_id = gym_spaces(:my_gym_boulder_space).id
    @sheet.build_row_json
    assert_not_nil @sheet.row_json
    assert @sheet.row_json.size >= 1
  end

  test 'build_row_json with gym_sector_ids filter' do
    sector = gym_sectors(:my_gym_sector)
    @sheet.gym_sector_ids = [sector.id]
    @sheet.build_row_json
    assert_equal 1, @sheet.row_json.size
    assert_equal sector.id, @sheet.row_json.first.with_indifferent_access[:sector][:id]
  end

  test 'build_row_json with gym_route_ids filter' do
    route = gym_routes(:gym_route_one)
    @sheet.gym_route_ids = [route.id]
    @sheet.build_row_json
    # Même avec un filtre sur une route, il devrait trouver le secteur de cette route
    assert @sheet.row_json.size >= 1
  end
end
