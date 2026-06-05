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
    
    # Wait a bit to ensure updated_at will change
    sleep 0.1
    
    # Use travel_to or similar if available, but here we just want to ensure time has passed
    # In some environments, touch might not change updated_at if it's in the same second
    # unless we force it.
    
    @guide_book_paper_crag.save # This should trigger touch_guide_book via after_create if it was new,
                                # but here it's already created.
    
    # Manually trigger the private method for testing if needed, 
    # or just perform an action that triggers it.
    @guide_book_paper_crag.send(:touch_guide_book)
    guide_book.reload
    
    assert_operator guide_book.updated_at, :>, last_update
  end
end
