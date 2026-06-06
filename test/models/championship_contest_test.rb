# frozen_string_literal: true

require 'test_helper'

class ChampionshipContestTest < ActiveSupport::TestCase
  setup do
    @championship_contest = championship_contests(:champ_contest_1)
  end

  test 'should be valid' do
    assert @championship_contest.valid?
  end

  test 'should belong to championship' do
    assert_instance_of Championship, @championship_contest.championship
  end

  test 'should belong to contest' do
    assert_instance_of Contest, @championship_contest.contest
  end

  test 'destroying championship_contest should destroy related category matches' do
    championship = @championship_contest.championship
    contest = @championship_contest.contest

    matches_count = ChampionshipCategoryMatch.joins(championship_category: :championship)
                                             .where(championship_categories: { championship_id: championship.id })
                                             .joins(:contest_category)
                                             .where(contest_categories: { contest_id: contest.id })
                                             .count
    assert matches_count.positive?

    @championship_contest.destroy

    # Verify matches are destroyed
    matches_count_after = ChampionshipCategoryMatch.joins(championship_category: :championship)
                                                   .where(championship_categories: { championship_id: championship.id })
                                                   .joins(:contest_category)
                                                   .where(contest_categories: { contest_id: contest.id })
                                                   .count
    assert_equal 0, matches_count_after
  end
end
