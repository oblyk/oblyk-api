# frozen_string_literal: true

require 'test_helper'

class ChampionshipTest < ActiveSupport::TestCase
  setup do
    @championship = championships(:championship_1)
  end

  test 'should be valid' do
    assert @championship.valid?
  end

  test 'should be invalid without name' do
    @championship.name = nil
    assert_not @championship.valid?
  end

  test 'should belong to gym' do
    assert_instance_of Gym, @championship.gym
  end

  test 'should have many championship_contests' do
    assert @championship.championship_contests.count >= 1
  end

  test 'should have many contests' do
    assert @championship.contests.count >= 1
  end

  test 'should have many championship_categories' do
    assert @championship.championship_categories.count >= 1
  end

  test 'summary_to_json returns expected structure' do
    json = @championship.summary_to_json
    assert_equal @championship.id, json[:id]
    assert_equal @championship.name, json[:name]
    assert json.key?(:contests_count)
    assert json.key?(:gym)
  end

  test 'detail_to_json returns expected structure' do
    json = @championship.detail_to_json
    assert_equal @championship.id, json[:id]
    assert json.key?(:contests)
    assert json.key?(:gym)
  end

  test 'results returns expected structure' do
    mock_results = [
      {
        category_id: contest_categories(:category_senior).id,
        genre: 'male',
        participants: [
          { first_name: 'John', last_name: 'Doe', date_of_birth: '1990-01-01', global_rank: 1 }
        ]
      }
    ]

    mock_service = Minitest::Mock.new
    mock_service.expect :results, mock_results

    ContestService::Result.stub :new, mock_service do
      results = @championship.results
      assert results.key?(:championship_results)
      assert results.key?(:contests)
      assert_instance_of Array, results[:championship_results]
    end
  end
end
