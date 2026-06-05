# frozen_string_literal: true

require 'test_helper'

class GymRouteOpenerTest < ActiveSupport::TestCase
  setup do
    @gym_route_opener = gym_route_openers(:gro_one)
  end

  test 'gym_route_opener is valid' do
    assert @gym_route_opener.valid?
  end

  test 'gym_route_opener belongs to a gym_opener' do
    assert_not_nil @gym_route_opener.gym_opener
  end

  test 'gym_route_opener belongs to a gym_route' do
    assert_not_nil @gym_route_opener.gym_route
  end
end
