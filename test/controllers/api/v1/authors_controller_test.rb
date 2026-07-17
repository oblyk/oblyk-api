# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AuthorsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @author = authors(:lucien)
        @user = users(:normal_user)
        @other_user = users(:super_admin_user)
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :super_admin_user)
        @public_headers = api_access_token_headers
      end

      test 'should show author' do
        get api_v1_author_url(@author), headers: @public_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @author.id, json_response['id']
        assert_equal @author.name, json_response['name']
      end

      test 'should update author' do
        put api_v1_author_url(@author),
            params: {
              author: {
                name: 'Lucien Updated',
                description: 'Nouvelle description'
              }
            },
            headers: @user_headers,
            as: :json
        assert_response :success
        @author.reload
        assert_equal 'Lucien Updated', @author.name
      end

      test 'should not update author if not owner' do
        put api_v1_author_url(@author),
            params: {
              author: {
                name: 'Hack'
              }
            },
            headers: @other_user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should return error on update with invalid params' do
        put api_v1_author_url(@author),
            params: {
              author: {
                name: ''
              }
            },
            headers: @user_headers,
            as: :json
        assert_response :unprocessable_content
      end

      test 'should add cover' do
        post add_cover_api_v1_author_url(@author),
             params: {
               author: {
                 cover: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
               }
             },
             headers: @user_headers
        assert_response :success
      end

      test 'should not add cover if not owner' do
        post add_cover_api_v1_author_url(@author),
             params: {
               author: {
                 cover: fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
               }
             },
             headers: @other_user_headers
        assert_response :forbidden
      end
    end
  end
end
