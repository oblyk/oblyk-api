# frozen_string_literal: true

require 'test_helper'

class GuideBookPdfSerializerTest < ActiveSupport::TestCase
  setup do
    @guide_book_pdf = guide_book_pdfs(:guide_book_pdf_1)
  end

  test 'It contains the basic attributes' do
    @guide_book_pdf.stub :pdf_url, 'http://test.com/test.pdf' do
      @serializer = GuideBookPdfSerializer.new(@guide_book_pdf)
      @serialization = JSON.parse(@serializer.serializable_hash.to_json)

      attributes = @serialization['data']['attributes']
      assert_equal @guide_book_pdf.id, attributes['id']
      assert_equal @guide_book_pdf.name, attributes['name']
      assert_equal @guide_book_pdf.description, attributes['description']
      assert_equal @guide_book_pdf.author, attributes['author']
      assert_equal @guide_book_pdf.publication_year, attributes['publication_year']
      assert_equal 'http://test.com/test.pdf', attributes['pdf_url']
      assert_equal @guide_book_pdf.created_at.as_json, attributes['history']['created_at']
      assert_equal @guide_book_pdf.updated_at.as_json, attributes['history']['updated_at']
    end
  end

  test 'It contains relationships' do
    @guide_book_pdf.stub :pdf_url, 'http://test.com/test.pdf' do
      @serializer = GuideBookPdfSerializer.new(@guide_book_pdf)
      @serialization = JSON.parse(@serializer.serializable_hash.to_json)

      relationships = @serialization['data']['relationships']
      assert_not_nil relationships['user']
      assert_not_nil relationships['crag']
      assert_equal @guide_book_pdf.user_id, relationships['user']['data']['id'].to_i
      assert_equal @guide_book_pdf.crag_id, relationships['crag']['data']['id'].to_i
    end
  end
end
