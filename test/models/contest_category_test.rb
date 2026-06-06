# frozen_string_literal: true

require 'test_helper'

class ContestCategoryTest < ActiveSupport::TestCase
  setup do
    @category_u18 = contest_categories(:category_u18)
    @category_senior = contest_categories(:category_senior)
    @category_custom = contest_categories(:category_custom)
    @contest = contests(:contest_1)
  end

  test 'category is valid' do
    assert @category_u18.valid?
  end

  test 'category is invalid without name' do
    @category_u18.name = nil
    assert_not @category_u18.valid?
    assert_includes @category_u18.errors.keys, :name
  end

  test 'category is invalid with wrong registration_obligation' do
    @category_u18.registration_obligation = 'wrong_obligation'
    assert_not @category_u18.valid?
    assert_includes @category_u18.errors.keys, :registration_obligation
  end

  test 'category between_age is invalid without min or max age' do
    @category_custom.min_age = nil
    @category_custom.max_age = nil
    assert_not @category_custom.valid?
    assert_includes @category_custom.errors.keys, :registration_obligation
  end

  test 'category with parity must have even capacity' do
    @category_u18.parity = true
    @category_u18.capacity = 11
    assert_not @category_u18.valid?
    assert_includes @category_u18.errors.keys, :capacity

    @category_u18.capacity = 10
    assert @category_u18.valid?
  end

  test 'under_age returns expected value' do
    assert_equal 18, @category_u18.under_age
    assert_equal 40, @category_senior.under_age
    assert_nil @category_custom.under_age
  end

  test 'over_age returns expected value based on categories in contest' do
    assert_equal 16, @category_u18.over_age
    assert_equal 0, contest_categories(:category_u16).over_age
    assert_equal 18, @category_senior.over_age

    @category_u18.min_age = 15
    assert_equal 15, @category_u18.over_age
  end

  test 'summary_to_json returns expected keys' do
    json = @category_u18.summary_to_json
    assert_equal @category_u18.id, json[:id]
    assert_equal @category_u18.name, json[:name]
    assert_includes json.keys, :under_age
    assert_includes json.keys, :over_age
    assert_includes json.keys, :gym
    assert_includes json.keys, :contest
  end

  test 'normalize_attributes handles blank values' do
    category = ContestCategory.new(
      name: 'Test Category',
      contest: @contest,
      description: '',
      registration_obligation: ''
    )
    category.valid?
    assert_nil category.description
    assert_nil category.registration_obligation
  end

  test 'set_order sets default order on create' do
    category = ContestCategory.create(
      name: 'New Category',
      contest: @contest
    )
    assert_equal 5, category.order
  end
end
