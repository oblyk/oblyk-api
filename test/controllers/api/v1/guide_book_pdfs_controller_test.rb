# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GuideBookPdfsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @crag = crags(:rocher_des_aures)
        @guide_book_pdf = guide_book_pdfs(:guide_book_pdf_1)
        @guide_book_pdf.pdf_file.attach(
          io: File.open(Rails.root.join('test/fixtures/files/test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        # Attach to other fixture to avoid delegation error in index
        guide_book_pdfs(:guide_book_pdf_without_user).pdf_file.attach(
          io: File.open(Rails.root.join('test/fixtures/files/test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)
      end

      test 'should get index' do
        get api_v1_guide_book_pdfs_url, params: { crag_id: @crag.id }, headers: @user_headers
        assert_response :success
      end

      test 'should show guide_book_pdf' do
        get api_v1_guide_book_pdf_url(@guide_book_pdf), headers: @user_headers
        assert_response :success
      end

      test 'should create guide_book_pdf' do
        pdf_file = fixture_file_upload('test/fixtures/files/test.pdf', 'application/pdf')
        assert_difference('GuideBookPdf.count', 1) do
          post api_v1_guide_book_pdfs_url,
               params: { guide_book_pdf: { name: 'New Topo PDF', crag_id: @crag.id, publication_year: 2024, pdf_file: pdf_file } },
               headers: @user_headers
        end
        assert_response :success
      end

      test 'should update guide_book_pdf' do
        pdf_file = fixture_file_upload('test/fixtures/files/test.pdf', 'application/pdf')
        patch api_v1_guide_book_pdf_url(@guide_book_pdf),
              params: { guide_book_pdf: { name: 'Updated Topo PDF', pdf_file: pdf_file } },
              headers: @user_headers
        assert_response :success
        @guide_book_pdf.reload
        assert_equal 'Updated Topo PDF', @guide_book_pdf.name
      end

      test 'should destroy guide_book_pdf by admin' do
        assert_difference('GuideBookPdf.count', -1) do
          delete api_v1_guide_book_pdf_url(@guide_book_pdf), headers: @admin_headers
        end
        assert_response :success
      end

      test 'should not destroy guide_book_pdf by normal user' do
        assert_no_difference('GuideBookPdf.count') do
          delete api_v1_guide_book_pdf_url(@guide_book_pdf), headers: @user_headers
        end
        assert_response :forbidden
      end
    end
  end
end
