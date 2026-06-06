# frozen_string_literal: true

require 'test_helper'

class ChampionshipCategoryTest < ActiveSupport::TestCase
  setup do
    @category = championship_categories(:cat_championship_senior)
  end

  test 'should be valid' do
    assert @category.valid?
  end

  test 'should be invalid without name' do
    @category.name = nil
    assert_not @category.valid?
  end

  test 'should belong to championship' do
    assert_instance_of Championship, @category.championship
  end

  test 'should have many championship_category_matches' do
    assert @category.championship_category_matches.count >= 1
  end

  test 'should have many contest_categories' do
    assert @category.contest_categories.count >= 1
  end

  test 'summary_to_json returns expected structure' do
    json = @category.summary_to_json
    assert_equal @category.id, json[:id]
    assert_equal @category.name, json[:name]
    assert_equal @category.championship_id, json[:championship_id]
    assert json.key?(:championship)
    assert json.key?(:contest_categories)
  end
end
