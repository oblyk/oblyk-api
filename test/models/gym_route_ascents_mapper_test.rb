# frozen_string_literal: true

require 'test_helper'

class GymRouteAscentsMapperTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @gym_route = gym_routes(:gym_route_one)
    @ascent = ascent_gym_routes(:gym_ascent_one)
  end

  test 'map_ascents maps ascents for a single route' do
    # On passe un hash car le mapper utilise route[:id]
    route_hash = @gym_route.summary_to_json
    mapper = GymRouteAscentsMapper.new(route_hash, @user)
    mapped_route = mapper.map_ascents

    assert_kind_of Hash, mapped_route
    assert mapped_route.key?(:my_ascents)
    assert_equal 1, mapped_route[:my_ascents].size
    assert_equal @ascent.id, mapped_route[:my_ascents].first[:id]
  end

  test 'map_ascents maps ascents for an array of routes' do
    routes = [
      @gym_route.summary_to_json,
      gym_routes(:gym_route_two).summary_to_json
    ]
    mapper = GymRouteAscentsMapper.new(routes, @user)
    mapped_routes = mapper.map_ascents

    assert_kind_of Array, mapped_routes
    assert_equal 2, mapped_routes.size
    
    # gym_route_one devrait avoir des ascensions
    assert mapped_routes[0].key?(:my_ascents)
    assert_equal 1, mapped_routes[0][:my_ascents].size
    
    # gym_route_two ne devrait pas en avoir
    assert_not mapped_routes[1].key?(:my_ascents)
  end

  test 'map_ascents returns original if no ascents found' do
    other_user = users(:super_admin_user)
    route_hash = @gym_route.summary_to_json
    mapper = GymRouteAscentsMapper.new(route_hash, other_user)
    mapped_route = mapper.map_ascents

    assert_not mapped_route.key?(:my_ascents)
  end
end
