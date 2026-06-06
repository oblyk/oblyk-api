# frozen_string_literal: true
require 'test_helper'

class GuideBookWebTest < ActiveSupport::TestCase
  setup do
    @guide_book_web = guide_book_webs(:guide_book_web_1)
  end

  test 'guide_book_web is valid' do
    assert @guide_book_web.valid?
  end

  test 'guide_book_web is invalid without name' do
    @guide_book_web.name = nil
    assert @guide_book_web.invalid?
  end

  test 'guide_book_web is invalid without url' do
    @guide_book_web.url = nil
    assert @guide_book_web.invalid?
  end

  test 'delegates latitude and longitude to crag' do
    assert_equal @guide_book_web.crag.latitude, @guide_book_web.latitude
    assert_equal @guide_book_web.crag.longitude, @guide_book_web.longitude
  end

  test 'detail_to_json returns correct keys' do
    json = @guide_book_web.detail_to_json
    assert_equal @guide_book_web.id, json[:id]
    assert_equal @guide_book_web.name, json[:name]
    assert_equal @guide_book_web.url, json[:url]
    assert_equal @guide_book_web.publication_year, json[:publication_year]
    assert_not_nil json[:crag]
    assert_not_nil json[:user]
    assert_not_nil json[:history]
  end

  test 'publication_push! creates a publication' do
    assert_difference 'Publication.count', 1 do
      assert_difference 'PublicationAttachment.count', 1 do
        @guide_book_web.publication_push!
      end
    end

    publication = Publication.last
    assert_equal @guide_book_web.crag_id, publication.publishable_id
    assert_equal 'Crag', publication.publishable_type

    attachment = PublicationAttachment.last
    assert_equal 'GuideBookWeb', attachment.attachable_type
    assert_equal @guide_book_web.id, attachment.attachable_id
  end
end
