# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PlaceOfSalesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @guide_book_paper = guide_book_papers(:guide_book_2024)
        @place_of_sale = place_of_sales(:one)
        @owner_headers = api_headers(user: :normal_user)
        @other_user_headers = api_headers(user: :other_user)
      end

      test 'should get index' do
        get api_v1_guide_book_paper_place_of_sales_url(guide_book_paper_id: @guide_book_paper.id), headers: api_access_token_headers
        assert_response :success
      end

      test 'should show place_of_sale' do
        get api_v1_guide_book_paper_place_of_sale_url(guide_book_paper_id: @guide_book_paper.id, id: @place_of_sale.id), headers: api_access_token_headers
        assert_response :success
      end

      test 'should create place_of_sale' do
        assert_difference('PlaceOfSale.count', 1) do
          post api_v1_guide_book_paper_place_of_sales_url(guide_book_paper_id: @guide_book_paper.id),
               params: {
                 place_of_sale: {
                   name: 'Nouveau point de vente',
                   latitude: 45.0,
                   longitude: 5.0
                 }
               },
               headers: @owner_headers, as: :json
        end
        assert_response :success
      end

      test 'should update place_of_sale' do
        patch api_v1_guide_book_paper_place_of_sale_url(guide_book_paper_id: @guide_book_paper.id, id: @place_of_sale.id),
              params: {
                place_of_sale: {
                  name: 'Nom modifié'
                }
              },
              headers: @owner_headers, as: :json
        assert_response :success
        @place_of_sale.reload
        assert_equal 'Nom modifié', @place_of_sale.name
      end

      test 'should not update place_of_sale if not owner' do
        patch api_v1_guide_book_paper_place_of_sale_url(guide_book_paper_id: @guide_book_paper.id, id: @place_of_sale.id),
              params: {
                place_of_sale: {
                  name: 'Tentative de modification'
                }
              },
              headers: @other_user_headers, as: :json
        assert_response :forbidden
      end

      test 'should destroy place_of_sale' do
        assert_difference('PlaceOfSale.count', -1) do
          delete api_v1_guide_book_paper_place_of_sale_url(guide_book_paper_id: @guide_book_paper.id, id: @place_of_sale.id), headers: @owner_headers
        end
        assert_response :success
      end

      test 'should not destroy place_of_sale if not owner' do
        assert_no_difference('PlaceOfSale.count') do
          delete api_v1_guide_book_paper_place_of_sale_url(guide_book_paper_id: @guide_book_paper.id, id: @place_of_sale.id), headers: @other_user_headers
        end
        assert_response :forbidden
      end
    end
  end
end
