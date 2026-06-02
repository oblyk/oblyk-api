# frozen_string_literal: true

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  setup do
    @department = departments(:drome)
  end

  test 'department is valid' do
    assert @department.valid?
  end

  test 'summary_to_json returns correct keys' do
    summary = @department.summary_to_json
    assert_equal @department.id, summary[:id]
    assert_equal @department.name, summary[:name]
    assert_equal @department.slug_name, summary[:slug_name]
    assert_equal @department.department_number, summary[:department_number]
    assert_equal @department.country.id, summary[:country][:id]
  end

  test 'detail_to_json returns complex figures' do
    detail = @department.detail_to_json
    assert_equal @department.id, detail[:id]
    assert_includes detail.keys, :towns
    assert_includes detail.keys, :guide_book_papers
    assert_includes detail.keys, :figures
    
    figures = detail[:figures]
    assert_equal @department.crags.count, figures[:crags][:count][:all]
    assert_equal @department.gyms.count, figures[:gyms][:count][:all]
    assert_equal @department.crag_routes.count, figures[:crag_routes][:count][:all]
  end

  test 'to_geo_json returns geojson format' do
    geo_json = @department.to_geo_json
    assert_equal 'Feature', geo_json[:type]
    assert_equal 'Department', geo_json[:properties][:type]
    assert_equal @department.name, geo_json[:properties][:name]
    assert_equal 'Polygon', geo_json[:geometry][:type]
    assert_equal @department.geo_polygon, geo_json[:geometry][:coordinates]
  end

  test 'belongs_to country' do
    assert_equal countries(:france), @department.country
  end

  test 'has_many crags' do
    assert_includes @department.crags, crags(:rocher_des_aures)
  end

  test 'route_figures returns figures for the department' do
    figures = @department.route_figures
    assert_kind_of Hash, figures
    assert_includes figures.keys, :route_count
    assert_includes figures.keys, :grade
  end
end
