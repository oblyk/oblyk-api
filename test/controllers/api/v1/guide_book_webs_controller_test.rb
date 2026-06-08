# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GuideBookWebsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @crag = crags(:rocher_des_aures)
        @guide_book_web = guide_book_webs(:guide_book_web_1)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_guide_book_webs_url, params: { crag_id: @crag.id }, headers: @user_headers
        assert_response :success
      end

      test 'should show guide_book_web' do
        get api_v1_guide_book_web_url(@guide_book_web), headers: @user_headers
        assert_response :success
      end

      test 'should create guide_book_web' do
        assert_difference('GuideBookWeb.count', 1) do
          post api_v1_guide_book_webs_url,
               params: { guide_book_web: { name: 'New Topo Web', url: 'https://oblyk.org', crag_id: @crag.id, publication_year: 2024 } },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update guide_book_web' do
        patch api_v1_guide_book_web_url(@guide_book_web),
              params: { guide_book_web: { name: 'Updated Topo Web' } },
              headers: @user_headers, as: :json
        assert_response :success
        @guide_book_web.reload
        assert_equal 'Updated Topo Web', @guide_book_web.name
      end

      test 'should destroy guide_book_web by admin' do
        assert_difference('GuideBookWeb.count', -1) do
          delete api_v1_guide_book_web_url(@guide_book_web), headers: @admin_headers
        end
        assert_response :success
      end

      test 'should not destroy guide_book_web by normal user' do
        assert_no_difference('GuideBookWeb.count') do
          delete api_v1_guide_book_web_url(@guide_book_web), headers: @user_headers
        end
        assert_response :forbidden
      end
    end
  end
end
