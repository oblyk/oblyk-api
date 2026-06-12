# frozen_string_literal: true

require 'test_helper'

class GuideBookPaperSerializerTest < ActiveSupport::TestCase
  setup do
    @guide_book_paper = guide_book_papers(:guide_book_2024)
    @serializer = GuideBookPaperSerializer.new(@guide_book_paper)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @guide_book_paper.id, attributes['id']
    assert_equal @guide_book_paper.name, attributes['name']
    assert_equal_or_nil @guide_book_paper.slug_name, attributes['slug_name']
    assert_equal @guide_book_paper.author, attributes['author']
    assert_equal @guide_book_paper.editor, attributes['editor']
    assert_equal @guide_book_paper.publication_year, attributes['publication_year']
    assert_equal @guide_book_paper.price_cents, attributes['price_cents']
    assert_equal_or_nil @guide_book_paper.ean, attributes['ean']
    assert_equal_or_nil @guide_book_paper.vc_reference, attributes['vc_reference']
    assert_equal_or_nil @guide_book_paper.number_of_page, attributes['number_of_page']
    assert_equal_or_nil @guide_book_paper.weight, attributes['weight']
    assert_equal @guide_book_paper.funding_status, attributes['funding_status']
    assert_equal_or_nil @guide_book_paper.follows_count, attributes['follows_count']
  end

  private

  def assert_equal_or_nil(expected, actual)
    if expected.nil?
      assert_nil actual
    else
      assert_equal expected, actual
    end
  end

  test 'It contains the calculated price' do
    attributes = @serialization['data']['attributes']
    expected_price = @guide_book_paper.price_cents.to_d / 100
    assert_equal expected_price.to_s, attributes['price']
  end
end
