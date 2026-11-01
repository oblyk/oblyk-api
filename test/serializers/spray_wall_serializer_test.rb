# frozen_string_literal: true

require "test_helper"

class SprayWallSerializerTest < ActiveSupport::TestCase
  setup do
    @spray_wall = spray_walls(:my_gym_spray_wall)
    @attributes = JSON.parse(SprayWallSerializer.new(@spray_wall).serializable_hash.to_json)["data"]["attributes"]
  end

  test "It exposes public and admin app paths matching front routes" do
    assert_equal "/gyms/#{@spray_wall.gym_id}/ma-salle/spray-walls/#{@spray_wall.id}", @attributes["app_path"]
    assert_equal "/gyms/#{@spray_wall.gym_id}/ma-salle/admins/spray-walls/#{@spray_wall.id}", @attributes["admin_app_path"]
  end

  test "It exposes holds and routes counts" do
    assert_equal @spray_wall.spray_wall_holds_count, @attributes["spray_wall_holds_count"]
    assert_equal @spray_wall.spray_wall_routes_count, @attributes["spray_wall_routes_count"]
  end
end
