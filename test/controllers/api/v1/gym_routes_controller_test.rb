# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @gym_sector = gym_sectors(:my_gym_sector)
        @gym_route = gym_routes(:gym_route_one)
        @user = users(:gym_route_setter_user)
        @headers = api_headers(user: :gym_route_setter_user)
      end

      test 'should get index' do
        get api_v1_gym_gym_space_gym_sector_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id, gym_sector_id: @gym_sector.id), headers: @headers
        assert_response :success
      end

      test 'should get index with route_ids' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { route_ids: [@gym_route.id] }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 1, json.size
        assert_equal @gym_route.id, json[0]['id']
      end

      test 'should get index with dismounted true' do
        @gym_route.dismount!
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { dismounted: true }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.any? { |r| r['id'] == @gym_route.id }
      end

      test 'should get index with group_by sector' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'sector' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.key?('sectors')
        assert json['sectors'].size > 0
        assert json['sectors'][0].key?('sector')
        assert json['sectors'][0].key?('routes')
      end

      test 'should get index with group_by opened_at' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'opened_at' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.key?('opened_at')
      end

      test 'should get index with group_by grade' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'grade' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.key?('grade')
      end

      test 'should get index with group_by level' do
        route_with_level = GymRoute.create!(
          name: 'Route with level',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ grade: '6a', grade_value: 32 }],
          level_index: 0
        )

        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'level' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.key?('level')
        assert json['level'].any? { |l| l['name'] == 0 && l['routes'].any? { |r| r['id'] == route_with_level.id } }
      end

      test 'should get index with group_by point and direction asc' do
        route_low = GymRoute.create!(
          name: 'Low Point Route',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ grade: '5a', grade_value: 20 }],
          points: 10
        )
        route_high = GymRoute.create!(
          name: 'High Point Route',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ grade: '8a', grade_value: 50 }],
          points: 1000
        )

        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'point', direction: 'asc' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json

        idx_low = json.index { |r| r['id'] == route_low.id }
        idx_high = json.index { |r| r['id'] == route_high.id }

        assert idx_low < idx_high, "Route with 10 points should be before route with 1000 points (direction asc)"
      end

      test 'should get index with order_by grade' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { order_by: 'grade', direction: 'desc' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.size >= 2
        v0 = json[0]['min_grade_value'] || 0
        v1 = json[1]['min_grade_value'] || 0
        assert v0 >= v1
      end

      test 'should get index with group_by point' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { group_by: 'point', direction: 'desc' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json
      end

      test 'should get index with order_by opened_at' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { order_by: 'opened_at', direction: 'asc' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json
      end

      test 'should get index with order_by level' do
        get api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { order_by: 'level', direction: 'asc' }, headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json
      end

      test 'should get print' do
        get print_api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { ids: [@gym_route.id] }, headers: @headers
        assert_response :success
        assert_equal 'application/pdf', response.content_type
      end

      test 'should get print with no ids' do
        get print_api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { ids: [] }, headers: @headers
        assert_response :success
        assert_equal 'application/pdf', response.content_type
      end

      test 'should get export' do
        get export_api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { ids: [@gym_route.id] }, headers: @headers
        assert_response :success
        assert_equal 'text/csv', response.content_type
        assert response.body.include?(@gym_route.name)
        assert response.body.include?("hold_colors\ttag_colors\tgrade\tpoints")
      end

      test 'should get export with no ids' do
        get export_api_v1_gym_gym_routes_url(gym_id: @gym.id), params: { ids: [] }, headers: @headers
        assert_response :success
        assert_equal 'text/csv', response.content_type
      end

      test 'should get paginated' do
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id), headers: @headers
        assert_response :success
      end

      test 'should get paginated with filters' do
        gym_route = GymRoute.create!(
          name: 'Grip Route',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ styles: ['grip'], grade: '6a', grade_value: 32 }]
        )

        filter = { type: 'style', value: 'grip' }.to_json
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { filters: [filter] },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.any? { |r| r['id'] == gym_route.id }

        filter = { type: 'style', value: 'dynamic' }.to_json
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { filters: [filter] },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.none? { |r| r['id'] == gym_route.id }
      end

      test 'should get paginated with sector filter' do
        filter = { type: 'sector', value: @gym_sector.id.to_s }.to_json
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { filters: [filter] },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.any? { |r| r['id'] == @gym_route.id }

        other_sector = gym_sectors(:my_gym_other_sector) rescue nil
        unless other_sector
          other_sector = GymSector.create!(
            name: 'Other Sector',
            gym_space: @gym_space,
            order: 2,
            height: 4,
            climbing_type: 'bouldering'
          )
        end

        filter = { type: 'sector', value: other_sector.id.to_s }.to_json
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { filters: [filter] },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        assert json.none? { |r| r['id'] == @gym_route.id }
      end

      test 'should get paginated with various order_by' do
        gym_level = gym_levels(:one)
        gym_level.update!(levels: [
          { order: 0, color: '#ff0000', label: 'Level 0' },
          { order: 1, color: '#00ff00', label: 'Level 1' },
          { order: 2, color: '#0000ff', label: 'Level 2' }
        ])

        route2 = GymRoute.create!(
          name: 'Route 2',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current - 1.day,
          sections: [{ grade: '7a', grade_value: 40 }],
          points: 100,
          level_index: 2,
          ascents_count: 10,
          likes_count: 5,
          all_comments_count: 3
        )

        route3 = GymRoute.create!(
          name: 'Route 3',
          gym_sector: @gym_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ grade: '5a', grade_value: 20 }],
          points: 50,
          level_index: 1,
          ascents_count: 20,
          likes_count: 10,
          all_comments_count: 1
        )

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'opened_at', direction: 'asc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx2 < idx3, 'Route 2 should be before Route 3 (opened_at asc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'grade', direction: 'desc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx2 < idx3, 'Route 2 (7a) should be before Route 3 (5a) (grade desc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'point', direction: 'desc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx2 < idx3, 'Route 2 (100 pts) should be before Route 3 (50 pts) (point desc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'level', direction: 'asc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx3 < idx2, 'Route 3 (level 1) should be before Route 2 (level 2) (level asc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'ascents_count', direction: 'desc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx3 < idx2, 'Route 3 (20 ascents) should be before Route 2 (10 ascents) (ascents_count desc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'likes_count', direction: 'desc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx3 < idx2, 'Route 3 (10 likes) should be before Route 2 (5 likes) (likes_count desc)'

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'comments_count', direction: 'desc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx2 = json.index { |r| r['id'] == route2.id }
        idx3 = json.index { |r| r['id'] == route3.id }
        assert idx2 < idx3, 'Route 2 (3 comments) should be before Route 3 (1 comment) (comments_count desc)'
      end

      test 'should get paginated with sector order' do
        other_sector = GymSector.create!(
          name: 'AAA Sector',
          gym_space: @gym_space,
          order: 1,
          height: 4,
          climbing_type: 'bouldering'
        )

        @gym_sector.update!(order: 2, name: 'ZZZ Sector')

        route_a = GymRoute.create!(
          name: 'Route AAA',
          gym_sector: other_sector,
          climbing_type: 'bouldering',
          opened_at: Date.current,
          sections: [{ grade: '6a', grade_value: 32 }]
        )

        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: { order_by: 'sector', direction: 'asc' },
            headers: @headers
        assert_response :success
        json = JSON.parse(response.body)
        idx_a = json.index { |r| r['id'] == route_a.id }
        idx_default = json.index { |r| r['id'] == @gym_route.id }

        assert idx_a < idx_default, 'Route in AAA Sector (order 1) should be before Route in ZZZ Sector (order 2)'
      end

      test 'should show gym route' do
        get api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers
        assert_response :success
      end

      test 'should create gym route' do
        assert_difference('GymRoute.count', 1) do
          post api_v1_gym_gym_space_gym_sector_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id, gym_sector_id: @gym_sector.id),
               params: {
                 gym_route: {
                   name: 'New Route',
                   climbing_type: 'bouldering',
                   height: 4,
                   opened_at: Date.current,
                   sections: [{ grade: '6a', grade_value: 32 }]
                 }
               },
               headers: @headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym route' do
        patch api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id),
              params: {
                gym_route: {
                  name: 'Updated Route Name'
                }
              },
              headers: @headers, as: :json
        assert_response :success
        @gym_route.reload
        assert_equal 'Updated Route Name', @gym_route.name
      end

      test 'should destroy gym route' do
        assert_difference('GymRoute.count', -1) do
          delete api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers, as: :json
        end
        assert_response :success
      end

      test 'should dismount gym route' do
        put dismount_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers, as: :json
        assert_response :success
        @gym_route.reload
        assert @gym_route.dismounted?
      end

      test 'should mount gym route' do
        @gym_route.dismount!
        put mount_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers, as: :json
        assert_response :success
        @gym_route.reload
        assert @gym_route.mounted?
      end

      test 'should dismount collection' do
        put dismount_collection_api_v1_gym_gym_routes_url(gym_id: @gym.id),
            params: { route_ids: [@gym_route.id] },
            headers: @headers, as: :json
        assert_response :no_content
        @gym_route.reload
        assert @gym_route.dismounted?
      end

      test 'should mount collection' do
        @gym_route.dismount!
        put mount_collection_api_v1_gym_gym_routes_url(gym_id: @gym.id),
            params: { route_ids: [@gym_route.id] },
            headers: @headers, as: :json
        assert_response :no_content
        @gym_route.reload
        assert @gym_route.mounted?
      end

      test 'should get similar sectors' do
        get similar_sectors_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers
        assert_response :success
      end

      test 'should get ascents' do
        get ascents_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers
        assert_response :success
      end

      test 'should get comments' do
        get comments_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers
        assert_response :success
      end

      test 'should add picture with new image' do
        assert_difference('GymRouteCover.count', 1) do
          post add_picture_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id),
               params: {
                 gym_route: {
                   gym_route_cover: {
                     picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
                   }
                 }
               },
               headers: @headers
        end
        assert_response :success
        @gym_route.reload
        assert @gym_route.gym_route_cover_id.present?
      end

      test 'should add picture with existing cover' do
        cover = gym_route_covers(:cover_one)
        post add_picture_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id),
             params: {
               gym_route: {
                 gym_route_cover_id: cover.id
               }
             },
             headers: @headers, as: :json
        assert_response :success
        @gym_route.reload
        assert_equal cover.id, @gym_route.gym_route_cover_id
      end

      test 'should replace picture' do
        @gym_route.gym_route_cover = GymRouteCover.create!(
          picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        )
        @gym_route.save!
        old_cover_id = @gym_route.gym_route_cover_id

        assert_no_difference('GymRouteCover.count') do
          post add_picture_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id),
               params: {
                 gym_route: {
                   gym_route_cover: {
                     picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
                   }
                 }
               },
               headers: @headers
        end
        assert_response :success
        @gym_route.reload
        assert_not_equal old_cover_id, @gym_route.gym_route_cover_id
        assert_nil GymRouteCover.find_by(id: old_cover_id)
      end

      test 'should delete picture' do
        @gym_route.gym_route_cover = GymRouteCover.create!(
          picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        )
        @gym_route.save!

        delete delete_picture_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id), headers: @headers, as: :json
        assert_response :success
        @gym_route.reload
        assert_nil @gym_route.gym_route_cover_id
      end

      test 'should add thumbnail' do
        post add_thumbnail_api_v1_gym_gym_route_url(gym_id: @gym.id, id: @gym_route.id),
              params: {
                gym_route: {
                  thumbnail: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg'),
                  thumbnail_position: { img_h: 1000, img_w: 1000, thb_h: 100, thb_w: 100, thb_y: 50, thb_x: 50 }.to_json
                }
              },
              headers: @headers
        assert_response :success
        @gym_route.reload
        assert @gym_route.thumbnail.attached?
        assert_equal 1000, @gym_route.thumbnail_position['img_h']
      end

      test 'should create opening sheet collection' do
        post opening_sheet_collection_api_v1_gym_gym_routes_url(gym_id: @gym.id),
             params: {
               gym_opening_sheet: {
                 title: 'New Opening Sheet',
                 number_of_columns: 3,
                 gym_route_ids: [@gym_route.id]
               }
             },
             headers: @headers, as: :json
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Opening Sheet', json['title']
        assert json.key?('id')
      end

      test 'should return error if opening sheet collection is invalid' do
        post opening_sheet_collection_api_v1_gym_gym_routes_url(gym_id: @gym.id),
             params: {
               gym_opening_sheet: {
                 title: '',
                 number_of_columns: 3
               }
             },
             headers: @headers, as: :json
        assert_response :unprocessable_content
        json = JSON.parse(response.body)
        assert json.key?('error')
      end
    end
  end
end
