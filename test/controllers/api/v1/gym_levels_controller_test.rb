# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymLevelsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @user = users(:gym_route_setter_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @gym_level = gym_levels(:one)
      end

      test 'should get index' do
        get api_v1_gym_gym_levels_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response
      end

      test 'should get index with average_for_sector_id' do
        sector = gym_sectors(:my_gym_sector)
        get api_v1_gym_gym_levels_url(gym_id: @gym.id, average_for_sector_id: sector.id), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response

        bouldering_level = json_response.find { |l| l['climbing_type'] == 'bouldering' }
        assert bouldering_level.present?

        level_with_average = bouldering_level['levels'].find { |l| l['order'] == 1 }
        assert_equal 34.0, level_with_average['average_grade'].to_f
      end

      test 'should update all gym levels' do
        put update_all_api_v1_gym_gym_levels_url(gym_id: @gym.id),
            params: {
              gym_levels: {
                bouldering: {
                  enabled: true,
                  grade_system: 'french',
                  levels: [
                    { order: 1, color: '#ff0000', default_grade: '5a', default_point: 150 }
                  ]
                },
                sport_climbing: {
                  enabled: false
                },
                pan: {
                  enabled: false
                }
              }
            },
            headers: @user_headers, as: :json
        assert_response :no_content
        @gym_level.reload
        assert_equal '5a', @gym_level.levels.first['default_grade']
        assert_equal 150, @gym_level.levels.first['default_point']
      end

      test 'should fail to update_all if not authorized' do
        other_user_headers = api_headers(user: :lulu)
        put update_all_api_v1_gym_gym_levels_url(gym_id: @gym.id),
            params: {
              gym_levels: {
                bouldering: { enabled: true },
                sport_climbing: { enabled: true },
                pan: { enabled: true }
              }
            },
            headers: other_user_headers, as: :json
        assert_response :no_content
      end
    end
  end
end
