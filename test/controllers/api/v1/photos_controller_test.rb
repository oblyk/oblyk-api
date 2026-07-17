# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PhotosControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @crag = crags(:rocher_des_aures)
        @article = articles(:article_1)

        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
        @public_headers = api_access_token_headers

        @photo = Photo.create!(
          user: @user,
          illustrable: @crag,
          description: 'Ma photo au Rocher des Aures',
          copyright_by: true,
          copyright_nc: false,
          copyright_nd: false
        )
        @photo.picture.attach(
          io: File.open(Rails.root.join('test/fixtures/files/image.jpg')),
          filename: 'image.jpg',
          content_type: 'image/jpeg'
        )
      end

      test 'should get index' do
        photo = Photo.last
        get api_v1_photos_url, params: { photo_ids: [photo.id] }, headers: @user_headers
        assert_response :success
      end

      test 'should show photo' do
        get api_v1_photo_url(@photo), headers: @user_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @photo.id, json_response['id']
      end

      test 'should create photo' do
        assert_difference('Photo.count', 1) do
          post api_v1_photos_url,
               params: {
                 photo: {
                   illustrable_type: 'Crag',
                   illustrable_id: @crag.id,
                   description: 'Nouvelle photo',
                   picture: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
                 }
               },
               headers: @user_headers
        end
        assert_response :success
      end

      test 'should fail to create photo with invalid params' do
        assert_no_difference('Photo.count') do
          post api_v1_photos_url,
               params: {
                 photo: {
                   illustrable_type: 'Crag',
                   illustrable_id: 99_999
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :unprocessable_content
      end

      test 'should update photo' do
        put api_v1_photo_url(@photo),
            params: {
              photo: {
                description: 'Description mise à jour'
              }
            },
            headers: @user_headers, as: :json
        assert_response :success
        @photo.reload
        assert_equal 'Description mise à jour', @photo.description
      end

      test 'should not update photo if not owner' do
        put api_v1_photo_url(@photo),
            params: {
              photo: {
                description: 'Tentative de hack'
              }
            },
            headers: @other_user_headers, as: :json
        assert_response :forbidden
      end

      test 'should destroy photo' do
        assert_difference('Photo.count', -1) do
          delete api_v1_photo_url(@photo), headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy photo if not owner' do
        assert_no_difference('Photo.count') do
          delete api_v1_photo_url(@photo), headers: @other_user_headers, as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
