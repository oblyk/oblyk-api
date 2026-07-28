# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class CragRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @crag_route = crag_routes(:route_one)
        @crag_route_tow = crag_routes(:route_two)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test "should get index" do
        get api_v1_crag_crag_routes_url(@crag), headers: @user_headers

        assert_response :success
      end

      test "should get index ordered by difficulty_asc" do
        get api_v1_crag_crag_routes_url(@crag), params: { order_by: "difficulty_asc", page: "all" }, headers: @user_headers

        assert_response :success

        body = response.parsed_body
        route_ids = body.map { |route| route["id"].to_i }

        assert_equal [
          crag_routes(:multi_pitch_route).id,
          crag_routes(:route_one).id,
          crag_routes(:route_two).id
        ], route_ids
      end

      test "should get index ordered by note" do
        get api_v1_crag_sector_crag_routes_url(@crag_route_tow.crag_sector), params: { order_by: "note", page: "all" }, headers: @user_headers

        assert_response :success

        body = response.parsed_body
        route_ids = body.map { |route| route["id"].to_i }

        assert_equal [
          crag_routes(:route_two).id
        ], route_ids
      end

      test "should get index ordered by popularity" do
        get api_v1_area_crag_routes_url(areas(:foret_de_saou)), params: { order_by: "popularity", page: "all" }, headers: @user_headers

        assert_response :success

        body = response.parsed_body
        route_ids = body.map { |route| route["id"].to_i }

        assert_equal [
          crag_routes(:multi_pitch_route).id,
          crag_routes(:route_one).id,
          crag_routes(:route_two).id
        ], route_ids
      end

      test "should get index ordered by name" do
        get api_v1_crag_routes_url(crag_id: @crag.id), params: { order_by: "name", page: "all" }, headers: @user_headers

        assert_response :success

        body = response.parsed_body
        route_ids = body.map { |route| route["id"].to_i }

        assert_equal [
          crag_routes(:multi_pitch_route).id,
          crag_routes(:route_one).id,
          crag_routes(:route_two).id
        ], route_ids
      end

      test "should show crag_route" do
        get api_v1_crag_route_url(@crag_route), headers: @user_headers

        assert_response :success
      end

      test "should get versions" do
        get versions_api_v1_crag_route_url(@crag_route), headers: @user_headers

        assert_response :success
        json_response = response.parsed_body

        assert json_response.key?("versions")
      end

      test "should get crag_route photos" do
        photo = Photo.new(
          illustrable: @crag_route,
          user: users(:normal_user)
        )
        photo.picture.attach(
          io: Rails.root.join("test/fixtures/files/image.jpg").open,
          filename: "image.jpg",
          content_type: "image/jpeg"
        )
        photo.save!

        get photos_api_v1_crag_route_url(@crag_route), headers: @user_headers

        assert_response :success
        json_response = response.parsed_body

        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
      end

      test "should get videos" do
        get videos_api_v1_crag_route_url(@crag_route), headers: @user_headers

        assert_response :success
        json_response = response.parsed_body

        assert_equal 1, json_response.size
      end

      test "should get random crag_route" do
        get random_api_v1_crag_routes_url, headers: @user_headers

        assert_response :success
        json_response = response.parsed_body

        assert json_response.key?("id")
      end

      test "should search crag_routes" do
        get search_api_v1_crag_routes_url, params: { query: "Route" }, headers: @user_headers

        assert_response :success
      end

      test "should search crag_routes in crag_sectors" do
        get search_api_v1_crag_routes_url(crag_sector_id: @crag_route_tow.crag_sector.id), params: { query: "Route" }, headers: @user_headers

        assert_response :success
      end

      test "should search crag_routes in crag" do
        get search_api_v1_crag_crag_routes_url(@crag), params: { query: "Route" }, headers: @user_headers

        assert_response :success
      end

      test "should search by grades globally" do
        get search_by_grades_api_v1_crag_routes_url, params: { grade: "7c" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 2, body.length
      end

      test "should obfuscate route names in search by grades when not logged in" do
        get search_by_grades_api_v1_crag_routes_url, params: { grade: "7c" }, headers: api_access_token_headers

        assert_response :success
        body = response.parsed_body

        assert body.all? { |route| route["name"].match?(/^[• ]+$/) } # Use [• ]+ to allow spaces if any
      end

      test "should return no content if grade parameter is missing" do
        get search_by_grades_api_v1_crag_routes_url, headers: @user_headers

        assert_response :no_content
      end

      test "should search by grades for a crag" do
        get search_by_grades_api_v1_crag_crag_routes_url(@crag), params: { grade: "6a+" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 2, body.length
      end

      test "should search by grades for a sector" do
        sector = crag_sectors(:sector_one)
        get search_by_grades_api_v1_crag_sector_crag_routes_url(sector), params: { grade: "7c" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 1, body.length
        assert_equal crag_routes(:route_two).id, body.first["id"]
      end

      test "should search by grades for an area" do
        area = areas(:foret_de_saou)
        get search_by_grades_api_v1_area_crag_routes_url(area), params: { grade: "6a+" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 2, body.length
      end

      test "should search by grade range" do
        get search_by_grades_api_v1_crag_crag_routes_url(@crag), params: { grade: "6a 7c" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 3, body.length
      end

      test "should search by level" do
        get search_by_grades_api_v1_crag_crag_routes_url(@crag), params: { grade: "6" }, headers: @user_headers

        assert_response :success
        body = response.parsed_body

        assert_equal 2, body.length
      end

      test "should get suggested_routes" do
        get suggested_routes_api_v1_crag_routes_url, headers: @user_headers

        assert_response :success

        body = response.parsed_body
        route_ids = body.pluck("id")

        assert_includes route_ids, crag_routes(:multi_pitch_route).id
        assert_not_includes route_ids, crag_routes(:route_one).id
        assert_not_includes route_ids, crag_routes(:route_two).id
        assert_not_includes route_ids, crag_routes(:petit_ange).id
      end

      test "should not get suggested_routes without session" do
        get suggested_routes_api_v1_crag_routes_url, headers: api_access_token_headers

        assert_response :unauthorized
      end

      test "should create crag_route" do
        assert_difference("CragRoute.count") do
          post api_v1_crag_crag_routes_url(@crag),
               params: {
                 crag_route: {
                   name: "New Route",
                   crag_id: @crag.id,
                   climbing_type: "sport_climbing",
                   sections: [ { grade: "6a", height: 20 } ]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test "should return unprocessable_content on create failure" do
        assert_no_difference("CragRoute.count") do
          post api_v1_crag_crag_routes_url(@crag),
               params: {
                 crag_route: {
                   name: "",
                   crag_id: @crag.id,
                   climbing_type: "sport_climbing",
                   sections: [ { grade: "6a", height: 20 } ]
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :unprocessable_content
      end

      test "should update crag_route" do
        put api_v1_crag_route_url(@crag_route),
            params: { crag_route: { name: "Updated Route Name" } },
            headers: @user_headers,
            as: :json

        assert_response :success
        @crag_route.reload

        assert_equal "Updated Route Name", @crag_route.name
      end

      test "should return unprocessable_content on update failure" do
        put api_v1_crag_route_url(@crag_route),
            params: { crag_route: { name: "" } },
            headers: @user_headers,
            as: :json

        assert_response :unprocessable_content
      end

      test "should destroy crag_route" do
        assert_difference("CragRoute.count", -1) do
          delete api_v1_crag_route_url(@crag_route), headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
