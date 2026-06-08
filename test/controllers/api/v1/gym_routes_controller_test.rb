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

      test 'should get paginated' do
        get paginated_api_v1_gym_gym_space_gym_routes_url(gym_id: @gym.id, gym_space_id: @gym_space.id), headers: @headers
        assert_response :success
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
    end
  end
end
