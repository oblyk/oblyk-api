# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class VideosControllerTest < ActionDispatch::IntegrationTest
      setup do
        @video_youtube = videos(:video_youtube)
        @video_vimeo = videos(:video_vimeo)
        @user = users(:normal_user)
        @user_two = users(:lulu)
        @crag = crags(:orpierre)
        @gym_route = gym_routes(:gym_route_one)
        @api_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_videos_url, params: { viewable_type: 'Crag', viewable_id: @crag.id }, headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should show video' do
        get api_v1_video_url(@video_youtube), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should create video' do
        assert_difference('Video.count') do
          post api_v1_videos_url,
               params: {
                 video: {
                   viewable_type: 'Crag',
                   viewable_id: @crag.id,
                   video_service: 'youtube',
                   url: 'https://www.youtube.com/watch?v=newvideo'
                 }
               },
               headers: @api_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should update video' do
        put api_v1_video_url(@video_youtube),
            params: {
              video: {
                description: 'Updated description'
              }
            },
            headers: @api_headers,
            as: :json
        assert_response :success
        @video_youtube.reload
        assert_equal 'Updated description', @video_youtube.description
      end

      test 'should not update video if not owner' do
        api_headers_user_two = api_headers(user: :lulu)
        put api_v1_video_url(@video_youtube),
            params: {
              video: {
                description: 'Updated description'
              }
            },
            headers: api_headers_user_two,
            as: :json
        assert_response :forbidden
      end

      test 'should destroy video' do
        assert_difference('Video.count', -1) do
          delete api_v1_video_url(@video_youtube), headers: @api_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy video if not owner' do
        api_headers_user_two = api_headers(user: :lulu)
        assert_no_difference('Video.count') do
          delete api_v1_video_url(@video_youtube), headers: api_headers_user_two, as: :json
        end
        assert_response :forbidden
      end

      test 'should moderate video by gym administrator' do
        video = Video.create!(
          user: @user_two,
          viewable: @gym_route,
          url: 'https://www.youtube.com/watch?v=gymvideo',
          video_service: 'youtube'
        )

        assert_difference('Video.count', -1) do
          delete moderate_by_gym_administrator_api_v1_video_url(video), headers: api_headers(user: :gym_route_setter_user), as: :json
        end
        assert_response :no_content
      end

      test 'should not moderate video if not gym administrator' do
        video = Video.create!(
          user: @user,
          viewable: @gym_route,
          url: 'https://www.youtube.com/watch?v=gymvideo',
          video_service: 'youtube'
        )

        api_headers_not_admin = api_headers(user: :other_user)

        delete moderate_by_gym_administrator_api_v1_video_url(video), headers: api_headers_not_admin, as: :json
        assert_response :forbidden
      end
      test 'should not moderate video if viewable is not a gym route' do
        delete moderate_by_gym_administrator_api_v1_video_url(@video_youtube), headers: @api_headers, as: :json
        assert_response :forbidden
      end
    end
  end
end
