# frozen_string_literal: true

require 'test_helper'

class AreaCragTest < ActiveSupport::TestCase
  setup do
    @area_crag = area_crags(:one)
  end

  test 'area_crag is valid' do
    assert @area_crag.valid?
  end

  test 'area_crag has area' do
    assert_not_nil @area_crag.area
    assert_equal areas(:foret_de_saou).id, @area_crag.area_id
  end

  test 'area_crag has crag' do
    assert_not_nil @area_crag.crag
    assert_equal crags(:rocher_des_aures).id, @area_crag.crag_id
  end

  test 'area_crag has user' do
    assert_not_nil @area_crag.user
    assert_equal users(:normal_user).id, @area_crag.user_id
  end

  test 'area_crag is invalid without area' do
    @area_crag.area = nil
    assert_not @area_crag.valid?
  end

  test 'area_crag is invalid without crag' do
    @area_crag.crag = nil
    assert_not @area_crag.valid?
  end

  test 'area_crag is invalid if crag is already in area' do
    duplicate_area_crag = AreaCrag.new(
      area: @area_crag.area,
      crag: @area_crag.crag
    )
    assert_not duplicate_area_crag.valid?
    assert_includes duplicate_area_crag.errors.attribute_names, :crag_id
  end
end
