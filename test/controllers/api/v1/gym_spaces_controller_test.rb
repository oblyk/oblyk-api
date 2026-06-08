# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymSpacesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @user_headers = api_headers(user: :gym_route_setter_user) # admin de l'espace dans les fixtures
        @other_user_headers = api_headers(user: :lulu) # pas admin de l'espace
      end

      test 'should get index' do
        get api_v1_gym_gym_spaces_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get groups' do
        get groups_api_v1_gym_gym_spaces_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should show gym space' do
        get api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id), headers: @user_headers
        assert_response :success
      end

      test 'should create gym space' do
        assert_difference('GymSpace.count', 1) do
          post api_v1_gym_gym_spaces_url(gym_id: @gym.id),
               params: {
                 gym_space: {
                   name: 'New Space',
                   climbing_type: 'bouldering',
                   order: 10
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym space' do
        patch api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
              params: {
                gym_space: {
                  name: 'Updated Space Name'
                }
              },
              headers: @user_headers, as: :json
        assert_response :success
        @gym_space.reload
        assert_equal 'Updated Space Name', @gym_space.name
      end

      test 'should destroy gym space' do
        assert_difference('GymSpace.count', -1) do
          delete api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
                 headers: @user_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should archive gym space' do
        put archived_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
            headers: @user_headers, as: :json
        assert_response :success
        @gym_space.reload
        assert_not_nil @gym_space.archived_at
      end

      test 'should unarchive gym space' do
        @gym_space.archive!
        put unarchived_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
            headers: @user_headers, as: :json
        assert_response :success
        @gym_space.reload
        assert_nil @gym_space.archived_at
      end

      test 'should get three_d_elements' do
        get three_d_elements_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
            headers: @user_headers
        assert_response :success
      end

      test 'should get tree_sectors' do
        get tree_sectors_api_v1_gym_gym_spaces_url(gym_id: @gym.id),
            headers: @user_headers
        assert_response :success
      end

      test_helper_file = 'files/image.jpg'

      test 'should add banner' do
        banner = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_banner_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { banner: banner } },
             headers: @user_headers
        assert_response :success
      end

      test 'should add plan' do
        plan = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_plan_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { plan: plan } },
             headers: @user_headers
        assert_response :success
      end

      test 'should not create gym space if not authorized' do
        post api_v1_gym_gym_spaces_url(gym_id: @gym.id),
             params: {
               gym_space: {
                 name: 'Unauthorized Space'
               }
             },
             headers: @other_user_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
