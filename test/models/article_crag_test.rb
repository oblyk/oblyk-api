# frozen_string_literal: true

require 'test_helper'

class ArticleCragTest < ActiveSupport::TestCase
  setup do
    @article_crag = article_crags(:article_crag_1)
  end

  test 'is valid' do
    assert @article_crag.valid?
  end

  test 'is invalid if it has no crag' do
    @article_crag.crag = nil
    assert_not @article_crag.valid?
  end

  test 'is invalid if it has no article' do
    @article_crag.article = nil
    assert_not @article_crag.valid?
  end

  test 'you cannot link the same route to the same crag twice' do
    duplicate_article_crag = ArticleCrag.new(
      article: @article_crag.article,
      crag: @article_crag.crag
    )
    assert_not duplicate_article_crag.valid?
  end

  test 'can link a different article to the same crag' do
    new_article_crag = ArticleCrag.new(
      article: articles(:article_2),
      crag: @article_crag.crag
    )
    assert new_article_crag.valid?
  end

  test "updates the crag's route counter" do
    crag = crags(:orpierre)
    initial_count = crag.articles_count || 0
    ArticleCrag.create!(
      article: articles(:article_1),
      crag: crag
    )
    assert_equal initial_count + 1, crag.reload.articles_count
  end

  test "updates the crag's timestamp upon creation" do
    crag = crags(:orpierre)
    old_updated_at = crag.updated_at
    ArticleCrag.create!(
      article: articles(:article_1),
      crag: crag
    )
    assert crag.reload.updated_at > old_updated_at
  end
end
