# frozen_string_literal: true

require 'test_helper'

class ArticleGuideBookPaperTest < ActiveSupport::TestCase
  setup do
    @article_guide_book_paper = article_guide_book_papers(:one)
  end

  test 'article_guide_book_paper is valid' do
    assert @article_guide_book_paper.valid?
  end

  test 'article_guide_book_paper has article' do
    assert_not_nil @article_guide_book_paper.article
    assert_equal articles(:article_1).id, @article_guide_book_paper.article_id
  end

  test 'article_guide_book_paper has guide_book_paper' do
    assert_not_nil @article_guide_book_paper.guide_book_paper
    assert_equal guide_book_papers(:guide_book_2024).id, @article_guide_book_paper.guide_book_paper_id
  end

  test 'article_guide_book_paper is invalid without article' do
    @article_guide_book_paper.article = nil
    assert_not @article_guide_book_paper.valid?
  end

  test 'article_guide_book_paper is invalid without guide_book_paper' do
    @article_guide_book_paper.guide_book_paper = nil
    assert_not @article_guide_book_paper.valid?
  end

  test 'article_guide_book_paper is invalid if article is already linked to guide_book_paper' do
    duplicate = ArticleGuideBookPaper.new(
      article: @article_guide_book_paper.article,
      guide_book_paper: @article_guide_book_paper.guide_book_paper
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors.keys, :article
  end
end
