# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GuideBookPapersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @crag = crags(:rocher_des_aures)
        @guide_book_paper = guide_book_papers(:guide_book_2024)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_guide_book_papers_url, headers: @user_headers
        assert_response :success
      end

      test 'should get grouped' do
        get grouped_api_v1_guide_book_papers_url, params: { group: 'publication_year' }, headers: @user_headers
        assert_response :success
      end

      test 'should get crags' do
        get crags_api_v1_guide_book_paper_url(@guide_book_paper), headers: @user_headers
        assert_response :success
      end

      test 'should get crags_figures' do
        get crags_figures_api_v1_guide_book_paper_url(@guide_book_paper), headers: @user_headers
        assert_response :success
      end

      test 'should show guide_book_paper' do
        get api_v1_guide_book_paper_url(@guide_book_paper), headers: @user_headers
        assert_response :success
      end

      test 'should create guide_book_paper' do
        assert_difference('GuideBookPaper.count', 1) do
          post api_v1_guide_book_papers_url,
               params: { guide_book_paper: { name: 'New Guide Book', publication_year: 2025 } },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update guide_book_paper' do
        patch api_v1_guide_book_paper_url(@guide_book_paper),
              params: { guide_book_paper: { name: 'Updated Guide Book' } },
              headers: @user_headers, as: :json
        assert_response :success
        @guide_book_paper.reload
        assert_equal 'Updated Guide Book', @guide_book_paper.name
      end

      test 'should destroy guide_book_paper by admin' do
        assert_difference('GuideBookPaper.count', -1) do
          delete api_v1_guide_book_paper_url(@guide_book_paper), headers: @admin_headers
        end
        assert_response :success
      end

      test 'should not destroy guide_book_paper by normal user' do
        assert_no_difference('GuideBookPaper.count') do
          delete api_v1_guide_book_paper_url(@guide_book_paper), headers: @user_headers
        end
        assert_response :forbidden
      end

      test 'should add crag to guide_book_paper' do
        new_crag = crags(:orpierre)
        assert_difference('GuideBookPaperCrag.count', 1) do
          post add_crag_api_v1_guide_book_paper_url(@guide_book_paper),
               params: { guide_book_paper: { crag_id: new_crag.id } },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should remove crag from guide_book_paper' do
        GuideBookPaperCrag.create(guide_book_paper: @guide_book_paper, crag: @crag, user: @user)

        assert_difference('GuideBookPaperCrag.count', -1) do
          delete remove_crag_api_v1_guide_book_paper_url(@guide_book_paper),
                 params: { guide_book_paper: { crag_id: @crag.id } },
                 headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should get around' do
        get around_api_v1_guide_book_papers_url,
            params: { lat: 44.44, lng: 5.14, dist: 20 },
            headers: @user_headers
        assert_response :success
      end
    end
  end
end
