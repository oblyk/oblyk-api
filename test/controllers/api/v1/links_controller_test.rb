# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class LinksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:other_user)
        @link = links(:link_1)
        @crag = crags(:orpierre)
        
        @user_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :other_user)
      end

      test 'should get index' do
        get api_v1_links_url,
            params: { linkable_type: 'Crag', linkable_id: @crag.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should show link' do
        get api_v1_link_url(@link),
            headers: @user_headers
        assert_response :success
      end

      test 'should create link' do
        assert_difference('Link.count', 1) do
          post api_v1_links_url,
               params: {
                 link: {
                   linkable_type: 'Crag',
                   linkable_id: @crag.id,
                   name: 'New Link',
                   url: 'https://newlink.com'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update link' do
        put api_v1_link_url(@link),
            params: {
              link: {
                name: 'Updated Name'
              }
            },
            headers: @user_headers, as: :json
        assert_response :success
        @link.reload
        assert_equal 'Updated Name', @link.name
      end

      test 'should destroy link' do
        assert_difference('Link.count', -1) do
          delete api_v1_link_url(@link),
                 headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should not update link of another user' do
        put api_v1_link_url(@link),
            params: {
              link: {
                name: 'Try to update'
              }
            },
            headers: @other_user_headers, as: :json
        assert_response :forbidden
      end

      test 'should not destroy link of another user' do
        assert_no_difference('Link.count') do
          delete api_v1_link_url(@link),
                 headers: @other_user_headers, as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
