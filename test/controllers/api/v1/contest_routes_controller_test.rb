# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ContestRoutesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @contest = contests(:contest_1)
        @contest_route = contest_routes(:route_1)
        @user = users(:normal_user)
        @admin = users(:super_admin_user)

        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_gym_contest_contest_routes_url(@gym, @contest), headers: @public_headers
        assert_response :success
      end

      test 'should show contest_route' do
        get api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route), headers: @public_headers
        assert_response :success
      end

      test 'should update contest_route' do
        put api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
            params: { contest_route: { name: 'Updated Route Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @contest_route.reload
        assert_equal 'Updated Route Name', @contest_route.name
      end

      test 'should disable contest_route' do
        put disable_api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
            headers: @admin_headers, as: :json
        assert_response :no_content
        @contest_route.reload
        assert_not_nil @contest_route.disabled_at
      end

      test 'should enable contest_route' do
        @contest_route.disable!
        put enable_api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
            headers: @admin_headers, as: :json
        assert_response :no_content
        @contest_route.reload
        assert_nil @contest_route.disabled_at
      end

      test 'should add picture' do
        dummy_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post add_picture_api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
             params: { contest_route: { picture: dummy_file } },
             headers: @admin_headers
        assert_response :no_content
      end

      test 'should delete picture' do
        delete delete_picture_api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
               headers: @admin_headers, as: :json
        assert_response :no_content
      end

      test 'should destroy contest_route' do
        @contest_route.contest_participant_ascents.destroy_all
        assert_difference('ContestRoute.count', -1) do
          delete api_v1_gym_contest_contest_route_url(@gym, @contest, @contest_route),
                 headers: @admin_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
