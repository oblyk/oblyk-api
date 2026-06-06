# frozen_string_literal: true

require 'test_helper'

class AscentGymRouteTest < ActiveSupport::TestCase
  setup do
    @ascent = ascent_gym_routes(:gym_ascent_one)
  end

  test 'ascent_gym_route is valid' do
    assert @ascent.valid?
  end

  test 'ascent_gym_route is invalid with wrong climbing_type' do
    @ascent.climbing_type = 'wrong_type'
    assert_not @ascent.valid?
  end

  test 'normalize_roping_status' do
    @ascent.ascent_status = 'project'
    @ascent.roping_status = 'lead_climb'
    @ascent.valid?
    assert_nil @ascent.roping_status
  end

  test 'points calculation' do
    @ascent.gym_route = nil
    assert_nil @ascent.points
  end
end
