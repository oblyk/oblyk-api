# frozen_string_literal: true

require 'test_helper'

class ContestRouteGroupCategoryTest < ActiveSupport::TestCase
  setup do
    @route_group_category = contest_route_group_categories(:route_group_1_cat_u16)
  end

  test 'contest_route_group_category is valid' do
    assert @route_group_category.valid?
  end

  test 'delete_results_cache is called after save' do
    mock_contest = Minitest::Mock.new
    mock_contest.expect :delete_results_cache, true

    @route_group_category.stub :contest, mock_contest do
      @route_group_category.save
    end
    assert_mock mock_contest
  end

  test 'delete_results_cache is called after destroy' do
    mock_contest = Minitest::Mock.new
    mock_contest.expect :delete_results_cache, true

    @route_group_category.stub :contest, mock_contest do
      @route_group_category.destroy
    end
    assert_mock mock_contest
  end
end
