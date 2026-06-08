# frozen_string_literal: true

require 'test_helper'

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

      test 'should create gym three d asset' do
        post api_v1_gym_gym_three_d_assets_url(gym_id: @gym.id),
             params: {
               gym_three_d_asset: {
                 name: 'New Asset',
                 import_type: 'gltf'
               }
             },
             headers: @admin_headers, as: :json
        assert_response :unprocessable_entity
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
                 picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
               }
             },
             headers: @admin_headers
        assert_response :success
      end
    end
  end
end
