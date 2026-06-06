# frozen_string_literal: true

require 'test_helper'

class ChampionshipCategoryMatchTest < ActiveSupport::TestCase
  setup do
    @match = championship_category_matches(:match_senior_1)
  end

  test 'should be valid' do
    assert @match.valid?
  end

  test 'should belong to championship_category' do
    assert_instance_of ChampionshipCategory, @match.championship_category
  end

  test 'should belong to contest_category' do
    assert_instance_of ContestCategory, @match.contest_category
  end
end
