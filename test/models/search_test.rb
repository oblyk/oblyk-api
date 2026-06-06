# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  test 'normalize_index_name simplifies the name' do
    assert_equal 'falaises', Search.normalize_index_name('Les Falaises')
    assert_equal 'grand-toit', Search.normalize_index_name('Le Grand Toit')
    assert_equal 'petit-bois', Search.normalize_index_name('Petit Bois')
    assert_equal 'evreux', Search.normalize_index_name('Evreux - Crag')
    assert_equal 'croix', Search.normalize_index_name('La Croix')
    assert_equal 'roche-abeille', Search.normalize_index_name('Roche de l\'Abeille')
    assert_equal 'petit-bois', Search.normalize_index_name('Le Petit Bois')
  end

  test 'ngram_splitter splits string correctly' do
    assert_equal ['test'], Search.ngram_splitter('test', 4)
    assert_equal %w[test ests stsa], Search.ngram_splitter('testsa', 4)
    assert_equal %w[abc bcd cde], Search.ngram_splitter('abcde', 3)
    assert_equal ['ab'], Search.ngram_splitter('ab', 3)
  end

  test 'delete_collection removes all records of a collection' do
    Search.push('Crag 1', 1, 'Crag')
    Search.push('Crag 2', 2, 'Crag')
    Search.push('Gym 1', 1, 'Gym')

    assert_difference 'Search.count', -2 do
      Search.delete_collection('Crag')
    end
    assert_equal 1, Search.count
    assert_equal 'Gym', Search.first.collection
  end

  test 'delete_object removes a specific object' do
    Search.push('Crag 1', 1, 'Crag')
    Search.push('Crag 2', 2, 'Crag')

    assert_difference 'Search.count', -1 do
      Search.delete_object('Crag', 1)
    end
    assert_equal 2, Search.first.index_id
  end

  test 'search returns relevant results' do
    Search.push('Céüse', 1, 'Crag', 'climbing')
    Search.push('Chamonix', 2, 'Crag', 'climbing')
    Search.push('Cham', 3, 'Crag', 'climbing')

    # Empty query
    assert_empty Search.search('', 'Crag', 'climbing')

    # Results by similarity
    results = Search.search('Ceuse', 'Crag', 'climbing')
    assert_includes results, 1
    
    results = Search.search('Cham', 'Crag', 'climbing')
    assert_includes results, 2
    assert_includes results, 3
  end

  test 'search with exact_name true' do
    Search.push('Céüse', 1, 'Crag', 'climbing')
    Search.push('Céüse Sud', 2, 'Crag', 'climbing')

    results = Search.search('Ceuse', 'Crag', 'climbing', exact_name: true)
    assert_includes results, 1
    assert_includes results, 2
  end

  test 'infinite_search returns paginated results' do
    30.times do |i|
      Search.push("Crag #{i}", i, 'Crag')
    end

    results_p1 = Search.infinite_search('Crag', 'Crag', 1)
    assert_equal 25, results_p1.size

    results_p2 = Search.infinite_search('Crag', 'Crag', 2)
    assert_equal 5, results_p2.size
  end
end
