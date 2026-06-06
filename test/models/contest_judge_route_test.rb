# frozen_string_literal: true

require 'test_helper'

class ContestJudgeRouteTest < ActiveSupport::TestCase
  setup do
    @judge_route = contest_judge_routes(:judge_route_1)
  end

  test 'contest judge route is valid' do
    assert @judge_route.valid?
  end

  test 'belongs to contest judge' do
    assert_instance_of ContestJudge, @judge_route.contest_judge
  end

  test 'belongs to contest route' do
    assert_instance_of ContestRoute, @judge_route.contest_route
  end
end
