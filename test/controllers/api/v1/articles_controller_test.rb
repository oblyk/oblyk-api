# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ArticlesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles(:article_1)
        @unpublished_article = articles(:article_2)
        @super_admin = users(:super_admin_user)
        @normal_user = users(:normal_user)
        @author = authors(:lucien)
        @public_headers = api_access_token_headers
        @admin_headers = api_headers(user: :super_admin_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_articles_url, headers: @public_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
      end

      test 'should show article' do
        get api_v1_article_url(@article), headers: @public_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @article.name, json_response['name']
      end

      test 'should view article' do
        post view_api_v1_article_url(@article), headers: @public_headers, as: :json
        assert_response :no_content
        @article.reload
        assert_equal 11, @article.views
      end

      test 'should get crags' do
        get crags_api_v1_article_url(@article), headers: @public_headers, as: :json
        assert_response :success
      end

      test 'should get guide_book_papers' do
        get guide_book_papers_api_v1_article_url(@article), headers: @public_headers, as: :json
        assert_response :success
      end

      test 'should get photos' do
        get photos_api_v1_article_url(@article), headers: @public_headers, as: :json
        assert_response :success
      end

      test 'should create article as super admin' do
        assert_difference('Article.count') do
          post api_v1_articles_url,
               params: {
                 article: {
                   name: 'New Article',
                   description: 'New Description',
                   body: 'New Body',
                   author_id: @author.id
                 }
               },
               headers: @admin_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should not create article as normal user' do
        assert_no_difference('Article.count') do
          post api_v1_articles_url,
               params: { article: { name: 'New Article' } },
               headers: @user_headers,
               as: :json
        end
        assert_response :forbidden
      end

      test 'should update article as super admin' do
        put api_v1_article_url(@article),
            params: { article: { name: 'Updated Name' } },
            headers: @admin_headers,
            as: :json
        assert_response :success
        @article.reload
        assert_equal 'Updated Name', @article.name
      end

      test 'should destroy article as super admin' do
        assert_difference('Article.count', -1) do
          delete api_v1_article_url(@article), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should publish article as super admin' do
        put publish_api_v1_article_url(@unpublished_article), headers: @admin_headers, as: :json
        assert_response :no_content
        @unpublished_article.reload
        assert @unpublished_article.published?
      end

      test 'should unpublish article as super admin' do
        put un_publish_api_v1_article_url(@article), headers: @admin_headers, as: :json
        assert_response :no_content
        @article.reload
        assert_not @article.published?
      end

      test 'should add crag to article' do
        crag = crags(:orpierre)
        post add_crag_api_v1_article_url(@article),
             params: { article: { crag_id: crag.id } },
             headers: @admin_headers,
             as: :json
        assert_response :no_content
        assert_includes @article.crags, crag
      end

      test 'should add guide book paper to article' do
        guide_book = guide_book_papers(:guide_book_2024)
        post add_guide_book_paper_api_v1_article_url(@article),
             params: { article: { guide_book_paper_id: guide_book.id } },
             headers: @admin_headers,
             as: :json
        assert_response :no_content
        assert_includes @article.guide_book_papers, guide_book
      end
    end
  end
end
