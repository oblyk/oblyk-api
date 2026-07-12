# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  setup do
    @article = articles(:article_1)
    @author = authors(:lucien)
  end

  test 'article should be valid' do
    assert @article.valid?
  end

  test 'article is invalid without name' do
    @article.name = nil
    assert_not @article.valid?
    assert_includes @article.errors.attribute_names, :name
  end

  test 'article is invalid without description' do
    @article.description = nil
    assert_not @article.valid?
    assert_includes @article.errors.attribute_names, :description
  end

  test 'article is invalid without body' do
    @article.body = nil
    assert_not @article.valid?
    assert_includes @article.errors.attribute_names, :body
  end

  test 'article is invalid without author' do
    @article.author = nil
    assert_not @article.valid?
    assert_includes @article.errors.attribute_names, :author
  end

  test 'view! increments views' do
    initial_views = @article.views || 0
    @article.view!
    assert_equal initial_views + 1, @article.views
  end

  test 'app_path returns correct path' do
    assert_equal "/articles/#{@article.id}/#{@article.slug_name}", @article.app_path
  end

  test 'summary_to_json returns correct structure' do
    summary = @article.summary_to_json
    assert_equal @article.id, summary[:id]
    assert_equal @article.name, summary[:name]
    assert_nil summary[:slug_name] unless @article.slug_name
    assert_equal @article.slug_name, summary[:slug_name] if @article.slug_name
    assert_equal @article.description, summary[:description]
    assert_equal @article.views, summary[:views]
    assert_equal @article.app_path, summary[:app_path]
  end

  test 'detail_to_json returns correct structure' do
    detail = @article.detail_to_json
    assert_equal @article.body, detail[:body]
    assert_equal @article.author_id, detail[:author_id]
    assert_kind_of Hash, detail[:author]
    assert_kind_of Array, detail[:crags]
    assert_kind_of Array, detail[:guide_book_papers]
  end

  test 'publication_push! creates a Publication for published article' do
    @article.published_at = Time.current
    assert @article.published?

    Publication.where(publishable_type: 'Article', publishable_id: @article.id).destroy_all

    assert_difference 'Publication.count', 1 do
      @article.publication_push!
    end

    publication = Publication.last
    assert_equal 'Article', publication.publishable_type
    assert_equal @article.id, publication.publishable_id
    assert_equal 'create', publication.publishable_subject
  end

  test 'publication_push! does not create Publication if already exists' do
    @article.published_at = Time.current
    @article.publication_push!

    assert_no_difference 'Publication.count' do
      @article.publication_push!
    end
  end

  test 'publication_push! does nothing if article is not published' do
    article = articles(:article_2)
    assert_not article.published?

    assert_no_difference 'Publication.count' do
      article.publication_push!
    end
  end
end
