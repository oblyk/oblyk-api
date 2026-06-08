# frozen_string_literal: true

require 'test_helper'

class PublishableTest < ActiveSupport::TestCase
  setup do
    @article = articles(:article_1)
  end

  test 'published scope returns only published objects' do
    @article.publish!
    assert_includes Article.published, @article

    @article.unpublish!
    assert_not_includes Article.published, @article
  end

  test 'unpublished scope returns only unpublished objects' do
    @article.unpublish!
    assert_includes Article.unpublished, @article

    @article.publish!
    assert_not_includes Article.unpublished, @article
  end

  test 'publish! sets published_at' do
    @article.unpublish!
    assert_nil @article.published_at
    @article.publish!
    assert_not_nil @article.published_at
  end

  test 'unpublish! clears published_at' do
    @article.publish!
    assert_not_nil @article.published_at
    @article.unpublish!
    assert_nil @article.published_at
  end

  test 'published? returns true if published_at is present' do
    @article.published_at = Time.current
    assert @article.published?

    @article.published_at = nil
    assert_not @article.published?
  end

  test 'unpublished? returns true if published_at is nil' do
    @article.published_at = nil
    assert @article.unpublished?

    @article.published_at = Time.current
    assert_not @article.unpublished?
  end
end
