# frozen_string_literal: true

require 'test_helper'

class GuideBookPaperCragTest < ActiveSupport::TestCase
  setup do
    @guide_book_paper_crag = guide_book_paper_crags(:one)
  end

  test 'guide_book_paper_crag is valid' do
    assert @guide_book_paper_crag.valid?
  end

  test 'guide_book_paper_crag is invalid without crag' do
    @guide_book_paper_crag.crag = nil
    assert @guide_book_paper_crag.invalid?
  end

  test 'guide_book_paper_crag is invalid without guide_book_paper' do
    @guide_book_paper_crag.guide_book_paper = nil
    assert @guide_book_paper_crag.invalid?
  end

  test 'guide_book_paper_crag is invalid if crag is already linked to the guide book' do
    duplicate = GuideBookPaperCrag.new(
      guide_book_paper: @guide_book_paper_crag.guide_book_paper,
      crag: @guide_book_paper_crag.crag
    )
    assert duplicate.invalid?
    assert_includes duplicate.errors[:crag], 'is_already_taken'
  end

  test 'touch_guide_book callback touches the guide book paper' do
    guide_book = @guide_book_paper_crag.guide_book_paper
    last_update = guide_book.updated_at

    @guide_book_paper_crag.save

    @guide_book_paper_crag.send(:touch_guide_book)
    guide_book.reload

    assert_operator guide_book.updated_at, :>, last_update
  end
end
