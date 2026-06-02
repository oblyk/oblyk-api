# frozen_string_literal: true

require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  setup do
    @country = countries(:france)
  end

  test 'country is valid' do
    assert @country.valid?
  end

  test 'summary_to_json returns correct keys' do
    summary = @country.summary_to_json
    assert_equal @country.id, summary[:id]
    assert_equal @country.name, summary[:name]
    assert_equal @country.code_country, summary[:code_country]
    assert_equal @country.slug_name, summary[:slug_name]
  end

  test 'detail_to_json returns summary' do
    assert_equal @country.summary_to_json, @country.detail_to_json
  end

  test 'has_many departments' do
    assert @country.departments.count >= 1
    assert_includes @country.departments, departments(:drome)
  end

  test 'has_many crags' do
    assert @country.crags.count >= 1
    assert_includes @country.crags, crags(:rocher_des_aures)
  end

  test 'route_figures returns figures for the country' do
    figures = @country.route_figures
    assert_kind_of Hash, figures
    assert_includes figures.keys, :route_count
    assert_includes figures.keys, :grade
  end
end
