# frozen_string_literal: true
require 'test_helper'

class GuideBookPdfTest < ActiveSupport::TestCase
  setup do
    @guide_book_pdf = guide_book_pdfs(:guide_book_pdf_1)
    @guide_book_pdf.pdf_file.attach(
      io: File.open(Rails.root.join('test/fixtures/files/test.pdf')),
      filename: 'test.pdf',
      content_type: 'application/pdf'
    )
  end

  test 'guide_book_pdf is valid' do
    assert @guide_book_pdf.valid?
  end

  test 'guide_book_pdf is invalid without name' do
    @guide_book_pdf.name = nil
    assert @guide_book_pdf.invalid?
  end

  test 'guide_book_pdf is invalid without pdf_file' do
    @guide_book_pdf.pdf_file.detach
    assert @guide_book_pdf.invalid?
  end

  test 'delegates latitude and longitude to crag' do
    assert_equal @guide_book_pdf.crag.latitude, @guide_book_pdf.latitude
    assert_equal @guide_book_pdf.crag.longitude, @guide_book_pdf.longitude
  end

  test 'detail_to_json returns correct keys' do
    json = @guide_book_pdf.detail_to_json
    assert_equal @guide_book_pdf.id, json[:id]
    assert_equal @guide_book_pdf.name, json[:name]
    assert_equal @guide_book_pdf.description, json[:description]
    assert_equal @guide_book_pdf.author, json[:author]
    assert_equal @guide_book_pdf.publication_year, json[:publication_year]
    assert_not_nil json[:pdf_file]
    assert_not_nil json[:crag]
    assert_not_nil json[:creator]
    assert_not_nil json[:history]
  end

  test 'pdf_url returns a string' do
    assert_kind_of String, @guide_book_pdf.pdf_url
  end

  test 'publication_push! creates a publication' do
    assert_difference 'Publication.count', 1 do
      assert_difference 'PublicationAttachment.count', 1 do
        @guide_book_pdf.publication_push!
      end
    end
    
    publication = Publication.last
    assert_equal @guide_book_pdf.crag_id, publication.publishable_id
    assert_equal 'Crag', publication.publishable_type
    
    attachment = PublicationAttachment.last
    assert_equal 'GuideBookPdf', attachment.attachable_type
    assert_equal @guide_book_pdf.id, attachment.attachable_id
  end
end
