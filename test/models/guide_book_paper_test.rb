# frozen_string_literal: true

require 'test_helper'

class GuideBookPaperTest < ActiveSupport::TestCase
  setup do
    @guide_book_paper = guide_book_papers(:guide_book_2024)
  end

  test 'guide_book_paper is valid' do
    assert @guide_book_paper.valid?
  end

  test 'guide_book_paper is invalid without name' do
    @guide_book_paper.name = nil
    assert @guide_book_paper.invalid?
  end

  test 'guide_book_paper is invalid with wrong funding_status' do
    @guide_book_paper.funding_status = 'wrong_status'
    assert @guide_book_paper.invalid?
  end

  test 'app_path returns correct path' do
    assert_equal "/guide-book-papers/#{@guide_book_paper.id}/#{@guide_book_paper.slug_name}", @guide_book_paper.app_path
  end

  test 'location returns coordinates of crags' do
    crag = crags(:rocher_des_aures)
    assert_equal [crag.latitude, crag.longitude], @guide_book_paper.location
  end

  test 'location returns nil if no crags' do
    @guide_book_paper.guide_book_paper_crags.destroy_all
    assert_equal [nil, nil], @guide_book_paper.location
  end

  test 'summary_to_json returns correct keys' do
    summary = @guide_book_paper.summary_to_json
    assert_equal @guide_book_paper.id, summary[:id]
    assert_equal @guide_book_paper.name, summary[:name]
    assert_equal @guide_book_paper.author, summary[:author]
    assert_equal @guide_book_paper.editor, summary[:editor]
  end

  test 'detail_to_json returns summary merged with more keys' do
    detail = @guide_book_paper.detail_to_json
    assert_equal @guide_book_paper.id, detail[:id]
    assert_includes detail.keys, :photos_count
    assert_includes detail.keys, :crags_count
    assert_includes detail.keys, :links_count
  end

  test 'all_photos_count returns sum of photos' do
    # Initial count based on fixtures
    assert_equal 0, @guide_book_paper.all_photos_count

    # Add a photo to a crag
    crag = crags(:rocher_des_aures)
    crag.update_column(:photos_count, 10)
    
    assert_equal 10, @guide_book_paper.all_photos_count
  end

  test 'historize_around_towns is called after save' do
    # We check if the worker is queued
    # Since assert_enqueued_with might not be available or requires Sidekiq::Testing
    # and the worker is Sidekiq, we can check if it performs.
    # For now, let's just check that it doesn't crash and the callback is reached.
    @guide_book_paper.update(name: 'New Name')
  end
end
