# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CommentsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @comment = comments(:comment_on_crag)
        @reply = comments(:reply_to_comment)
        @user = users(:normal_user)
        @admin = users(:super_admin_user)
        @crag = crags(:rocher_des_aures)
        @gym_route = gym_routes(:gym_route_one)

        @public_headers = api_access_token_headers
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_comments_url, params: { commentable_type: 'Crag', commentable_id: @crag.id }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Hash, json_response
        assert json_response.key?('data')
      end

      test 'should get comments for a comment (replies)' do
        get comments_api_v1_comment_url(@comment), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Hash, json_response
        assert json_response.key?('data')
      end

      test 'should show comment' do
        get api_v1_comment_url(@comment), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @comment.body, json_response['data']['attributes']['body']
      end

      test 'should create comment' do
        assert_difference('Comment.count') do
          post api_v1_comments_url,
               params: {
                 comment: {
                   commentable_type: 'Crag',
                   commentable_id: @crag.id,
                   body: 'New comment'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update comment' do
        put api_v1_comment_url(@comment),
            params: { comment: { body: 'Updated body' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @comment.reload
        assert_equal 'Updated body', @comment.body
      end

      test 'should not update comment of another user' do
        other_user_headers = api_headers(user: :super_admin_user)
        put api_v1_comment_url(@comment),
            params: { comment: { body: 'Try to update' } },
            headers: other_user_headers,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy comment' do
        comment_to_destroy = Comment.create!(
          user: @user,
          commentable: @crag,
          body: 'To be destroyed'
        )
        assert_difference('Comment.count', -1) do
          delete api_v1_comment_url(comment_to_destroy), headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should moderate comment by gym administrator' do
        gym_comment = Comment.create!(
          user: @user,
          commentable: @gym_route,
          body: 'Comment to moderate'
        )

        delete moderate_by_gym_administrator_api_v1_comment_url(gym_comment),
               headers: @admin_headers,
               as: :json

        assert_response :no_content
        gym_comment.reload
        assert_not_nil gym_comment.moderated_at
      end

      test 'should not moderate comment if not gym administrator' do
        gym_comment = Comment.create!(
          user: @admin,
          commentable: @gym_route,
          body: 'Comment to moderate'
        )

        non_admin_user = User.create!(
          first_name: 'No',
          last_name: 'Admin',
          email: 'no-admin@test.com',
          password: 'Password123!',
          uuid: SecureRandom.uuid,
          slug_name: 'no-admin'
        )

        token = generate_token(non_admin_user)
        non_admin_headers = {
          'Authorization' => token,
          'HttpApiAccessToken' => organizations(:oblyk_orga).api_access_token,
          'Content-Type' => 'application/json'
        }

        delete moderate_by_gym_administrator_api_v1_comment_url(gym_comment),
               headers: non_admin_headers,
               as: :json

        assert_response :forbidden
      end
    end
  end
end
