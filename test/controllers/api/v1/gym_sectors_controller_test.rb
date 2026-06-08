# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymSectorsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @gym_sector = gym_sectors(:my_gym_sector)
        @user = users(:gym_route_setter_user)
        @headers = api_headers(user: :gym_route_setter_user)
      end

      test 'should get index' do
        get api_v1_gym_gym_space_gym_sectors_url(gym_id: @gym.id, gym_space_id: @gym_space.id), headers: @headers
        assert_response :success
      end

      test 'should show gym sector' do
        get api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id), headers: @headers
        assert_response :success
      end

      test 'should create gym sector' do
        assert_difference('GymSector.count', 1) do
          post api_v1_gym_gym_space_gym_sectors_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
               params: {
                 gym_sector: {
                   name: 'New Sector',
                   order: 2,
                   climbing_type: 'bouldering',
                   height: 4
                 }
               },
               headers: @headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym sector' do
        patch api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id),
              params: {
                gym_sector: {
                  name: 'Updated Sector Name'
                }
              },
              headers: @headers, as: :json
        assert_response :success
        @gym_sector.reload
        assert_equal 'Updated Sector Name', @gym_sector.name
      end

      test 'should bulk update gym sectors' do
        put bulk_update_api_v1_gym_gym_space_gym_sectors_url(gym_id: @gym.id, gym_space_id: @gym_space.id),
            params: {
              gym_sectors: [
                {
                  id: @gym_sector.id,
                  name: 'Bulk Updated Name',
                  order: 10,
                  height: 4.5
                }
              ]
            },
            headers: @headers, as: :json
        assert_response :success
        @gym_sector.reload
        assert_equal 'Bulk Updated Name', @gym_sector.name
        assert_equal 10, @gym_sector.order
      end

      test 'should destroy gym sector' do
        assert_difference('GymSector.count', -1) do
          delete api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id),
                 headers: @headers, as: :json
        end
        assert_response :no_content
      end

      test 'should dismount routes in sector' do
        # On s'assure qu'il y a des voies montées
        assert @gym_sector.gym_routes.mounted.count.positive?
        
        delete dismount_routes_api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id),
               headers: @headers, as: :json
        assert_response :success
        assert_equal 0, @gym_sector.gym_routes.mounted.count
      end

      test 'should get last routes with pictures' do
        get last_routes_with_pictures_api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id),
            headers: @headers
        assert_response :success
      end

      test 'should delete three d path' do
        delete delete_three_d_path_api_v1_gym_gym_space_gym_sector_url(gym_id: @gym.id, gym_space_id: @gym_space.id, id: @gym_sector.id),
               headers: @headers, as: :json
        assert_response :no_content
        @gym_sector.reload
        assert_nil @gym_sector.three_d_path
      end
    end
  end
end
