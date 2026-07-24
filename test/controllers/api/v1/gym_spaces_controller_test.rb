# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymSpacesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @gym_space = gym_spaces(:my_gym_boulder_space)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @other_user_headers = api_headers(user: :lulu)
        @visitor_headers = api_headers(user: :normal_user)
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

      test 'should forbidden show gym space draft for visitor' do
        @gym_space.update_column :draft, true
        get api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id), headers: @visitor_headers
        assert_response :forbidden
      end

      test 'should show gym space draft for gym team user' do
        @gym_space.update_column :draft, true
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

      test 'should not create gym space with invalid params' do
        assert_no_difference('GymSpace.count') do
          post api_v1_gym_gym_spaces_url(gym_id: @gym.id),
               params: {
                 gym_space: {
                   name: '',
                   climbing_type: 'bouldering'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :unprocessable_content
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

      test 'should not update gym space with invalid params' do
        patch api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
              params: {
                gym_space: {
                  name: ''
                }
              },
              headers: @user_headers, as: :json
        assert_response :unprocessable_content
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

      test_helper_file = 'image.jpg'

      test 'should add banner' do
        banner = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_banner_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { banner: banner } },
             headers: @user_headers
        assert_response :success
      end

      test 'should not add banner with invalid file' do
        invalid_banner = fixture_file_upload('test.pdf', 'application/pdf')
        post add_banner_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { banner: invalid_banner } },
             headers: @user_headers
        assert_response :unprocessable_content
      end

      test 'should add plan' do
        plan = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_plan_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { plan: plan } },
             headers: @user_headers
        assert_response :success
      end

      test 'should not add plan with invalid file' do
        invalid_plan = fixture_file_upload('test.pdf', 'application/pdf')
        post add_plan_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: { gym_space: { plan: invalid_plan } },
             headers: @user_headers
        assert_response :unprocessable_content
      end

      test 'should add three_d_capture' do
        picture = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_three_d_capture_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 three_d_picture: picture,
                 three_d_camera_position: { x: 1, y: 2, z: 3 },
                 three_d_rotation: { x: 0, y: 0, z: 0 }
               }
             },
             headers: @user_headers
        assert_response :success
      end

      test 'should not add three_d_capture with invalid file' do
        invalid_picture = fixture_file_upload('test.pdf', 'application/pdf')
        post add_three_d_capture_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 three_d_picture: invalid_picture
               }
             },
             headers: @user_headers
        assert_response :unprocessable_content
      end

      test 'should add three_d_file gltf' do
        gltf_file = fixture_file_upload('espace_voie.gltf', 'model/gltf+json')
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'gltf',
                 three_d_file: gltf_file
               }
             },
             headers: @user_headers
        assert_response :success
      end

      test 'should not add three_d_file with wrong format' do
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'gltf',
                 three_d_file: fixture_file_upload(test_helper_file, 'image/jpeg')
               }
             },
             headers: @user_headers
        assert_response :unprocessable_content
      end

      test 'should not add three_d_file if not authorized' do
        gltf_file = fixture_file_upload('espace_voie.gltf', 'model/gltf+json')
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'gltf',
                 three_d_file: gltf_file
               }
             },
             headers: @other_user_headers
        assert_response :forbidden
      end

      test 'should add three_d_file obj_zip' do
        zip_file = fixture_file_upload('test.obj.zip', 'application/zip')
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'obj_zip',
                 three_d_file: zip_file
               }
             },
             headers: @user_headers
        assert_includes [200, 422], response.status
      end

      test 'should add three_d_file obj_mtl' do
        obj_file = fixture_file_upload('test.obj/e5230e1b-0345-4195-9f18-95cad10e8c94.obj', 'text/plain')
        mtl_file = fixture_file_upload('test.obj/e5230e1b-0345-4195-9f18-95cad10e8c94.mtl', 'text/plain')
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'obj_mtl',
                 three_d_file_obj: obj_file,
                 three_d_file_mtl: mtl_file
               }
             },
             headers: @user_headers
        assert_includes [200, 422], response.status
      end

      test 'should not add three_d_file obj_mtl with wrong format' do
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'obj_mtl',
                 three_d_file_obj: fixture_file_upload('image.jpg', 'image/jpeg'),
                 three_d_file_mtl: fixture_file_upload('image.jpg', 'image/jpeg')
               }
             },
             headers: @user_headers
        assert_response :unprocessable_content
      end

      test 'should not add three_d_file with unknown import_type' do
        post add_three_d_file_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 import_type: 'unknown_type'
               }
             },
             headers: @user_headers, as: :json
        assert_response :unprocessable_content
      end

      test 'should not add three_d_capture if not authorized' do
        picture = fixture_file_upload(test_helper_file, 'image/jpeg')
        post add_three_d_capture_api_v1_gym_gym_space_url(gym_id: @gym.id, id: @gym_space.id),
             params: {
               gym_space: {
                 three_d_picture: picture
               }
             },
             headers: @other_user_headers
        assert_response :forbidden
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
