# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

module Api
  module V1
    class GymThreeDAssetsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @asset = gym_three_d_assets(:asset_2)
        @admin_headers = api_headers(user: :gym_route_setter_user)
        @user_headers = api_headers(user: :lulu)
      end

      test 'should get index' do
        get api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should show gym three d asset' do
        get api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: @asset.id), headers: @user_headers
        assert_response :success
      end

      test 'should create gym three d asset with gltf' do
        assert_difference('GymThreeDAsset.count') do
          post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
               params: {
                 gym_three_d_asset: {
                   name: 'New Asset',
                   import_type: 'gltf',
                   three_d_file: fixture_file_upload('espace_voie.gltf', 'model/gltf+json')
                 }
               },
               headers: @admin_headers
        end
        assert_response :success
      end

      test 'should create gym three d asset with obj_zip' do
        Open3.stub :capture3, [nil, nil, Minitest::Mock.new.expect(:success?, true)] do
          gltf_path = Rails.root.join('tmp/test_asset.gltf').to_s
          FileUtils.cp('test/fixtures/files/espace_voie.gltf', gltf_path)
          Api::V1::GymThreeDAssetsController.alias_method :original_attach_three_d_file, :attach_three_d_file
          Api::V1::GymThreeDAssetsController.define_method(:attach_three_d_file) do
            file = File.open(gltf_path, 'r')
            @gym_three_d_asset.three_d_gltf.attach(io: file, filename: 'test.gltf', content_type: 'model/gltf+json')
            true
          end
          begin
            assert_difference('GymThreeDAsset.count') do
              post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
                   params: {
                     gym_three_d_asset: {
                       name: 'New Asset Zip',
                       import_type: 'obj_zip',
                       three_d_file: fixture_file_upload('test.obj.zip', 'application/zip')
                     }
                   },
                   headers: @admin_headers
            end
            assert_response :success
          ensure
            Api::V1::GymThreeDAssetsController.alias_method :attach_three_d_file, :original_attach_three_d_file
            Api::V1::GymThreeDAssetsController.remove_method :original_attach_three_d_file
            FileUtils.rm_f(gltf_path)
          end
        end
      end

      test 'should create gym three d asset with obj_mtl' do
        Open3.stub :capture3, [nil, nil, Minitest::Mock.new.expect(:success?, true)] do
          gltf_path = Rails.root.join('tmp/test_asset_mtl.gltf').to_s
          FileUtils.cp('test/fixtures/files/espace_voie.gltf', gltf_path)
          Api::V1::GymThreeDAssetsController.alias_method :original_attach_three_d_file, :attach_three_d_file
          Api::V1::GymThreeDAssetsController.define_method(:attach_three_d_file) do
            file = File.open(gltf_path, 'r')
            @gym_three_d_asset.three_d_gltf.attach(io: file, filename: 'test.gltf', content_type: 'model/gltf+json')
            true
          end

          begin
            assert_difference('GymThreeDAsset.count') do
              post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
                   params: {
                     gym_three_d_asset: {
                       name: 'New Asset Obj Mtl',
                       import_type: 'obj_mtl',
                       three_d_file_obj: fixture_file_upload('test.obj/e5230e1b-0345-4195-9f18-95cad10e8c94.obj', 'text/plain'),
                       three_d_file_mtl: fixture_file_upload('test.obj/e5230e1b-0345-4195-9f18-95cad10e8c94.mtl', 'text/plain')
                     }
                   },
                   headers: @admin_headers
            end
            assert_response :success
          ensure
            Api::V1::GymThreeDAssetsController.alias_method :attach_three_d_file, :original_attach_three_d_file
            Api::V1::GymThreeDAssetsController.remove_method :original_attach_three_d_file
            FileUtils.rm_f(gltf_path)
          end
        end
      end

      test 'should handle obj2gltf failure' do
        Open3.stub :capture3, [nil, 'error', Minitest::Mock.new.expect(:success?, false)] do
          RorVsWild.stub :record_error, true do
            post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
                 params: {
                   gym_three_d_asset: {
                     name: 'Fail Asset',
                     import_type: 'obj_zip',
                     three_d_file: fixture_file_upload('test.obj.zip', 'application/zip')
                   }
                 },
                 headers: @admin_headers
            assert_response :unprocessable_content
          end
        end
      end

      test 'should not create gym three d asset with wrong format' do
        post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
             params: {
               gym_three_d_asset: {
                 name: 'New Asset',
                 import_type: 'gltf',
                 three_d_file: fixture_file_upload('image.jpg', 'image/jpeg')
               }
             },
             headers: @admin_headers
        assert_response :unprocessable_content
      end

      test 'should update gym three d asset' do
        patch api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: @asset.id),
              params: {
                gym_three_d_asset: {
                  name: 'Updated Name'
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @asset.reload
        assert_equal 'Updated Name', @asset.name
      end

      test 'should destroy gym three d asset' do
        asset = GymThreeDAsset.create!(name: 'Temp', gym: @gym)
        assert_difference('GymThreeDAsset.count', -1) do
          delete api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: asset.id),
                 headers: @admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should not create if not admin' do
        post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
             params: {
               gym_three_d_asset: {
                 name: 'Unauthorized Asset'
               }
             },
             headers: @user_headers, as: :json
        assert_response :forbidden
      end

      test 'should add picture' do
        post add_picture_api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: @asset.id),
             params: {
               gym_three_d_asset: {
                 picture: fixture_file_upload('image.jpg', 'image/jpeg')
               }
             },
             headers: @admin_headers
        assert_response :success
      end

      test 'should change three d file' do
        put change_three_d_file_api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: @asset.id),
             params: {
               gym_three_d_asset: {
                 three_d_gltf: fixture_file_upload('espace_voie.gltf', 'model/gltf+json')
               }
             },
             headers: @admin_headers
        assert_response :success
      end

      test 'should get index without administration' do
        get api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should show gym three d asset without administration' do
        get api_v1_gym_gym_three_d_asset_url(gym_id: @gym.id, id: @asset.id), headers: @user_headers
        assert_response :success
      end
    end
  end
end
