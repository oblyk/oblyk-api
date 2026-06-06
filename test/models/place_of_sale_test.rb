# frozen_string_literal: true

require 'test_helper'

class PlaceOfSaleTest < ActiveSupport::TestCase
  setup do
    @place_of_sale = place_of_sales(:one)
  end

  test 'place of sale is valid' do
    assert @place_of_sale.valid?
  end

  test 'place of sale is invalid without name' do
    @place_of_sale.name = nil
    assert_not @place_of_sale.valid?
  end

  test 'place of sale is invalid without guide_book_paper' do
    @place_of_sale.guide_book_paper = nil
    assert_not @place_of_sale.valid?
  end

  test 'location returns latitude and longitude' do
    assert_equal [45.75, 4.85], @place_of_sale.location
  end

  test 'to_geo_json returns expected format' do
    geo_json = @place_of_sale.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'PlaceOfSale', geo_json[:properties][:type]
    assert_equal @place_of_sale.id, geo_json[:properties][:id]
    assert_equal 'Vieux Campeur', geo_json[:properties][:name]
    assert_equal [4.85, 45.75, 0.0], geo_json[:geometry][:coordinates]
  end

  test 'to_geo_json with minimalistic option' do
    geo_json = @place_of_sale.to_geo_json(minimalistic: true)
    assert_equal 'Feature', geo_json[:type]
    assert_nil geo_json[:properties][:name]
    assert_equal @place_of_sale.id, geo_json[:properties][:id]
  end

  test 'detail_to_json returns expected keys' do
    json = @place_of_sale.detail_to_json
    assert_equal @place_of_sale.id, json[:id]
    assert_equal 'Vieux Campeur', json[:name]
    assert_equal @place_of_sale.guide_book_paper_id, json[:guide_book_paper_id]
    assert json.key?(:creator)
    assert json.key?(:history)
  end
end
