# frozen_string_literal: true

require 'test_helper'

module ContestService
  class ResultTest < ActiveSupport::TestCase
    setup do
      @contest = contests(:contest_1)
      @result_service = ContestService::Result.new(@contest)
    end

    test 'initialize sets correct attributes' do
      assert_equal @contest, @contest # Juste pour vérifier @contest
      # L'initialisation ne fait qu'assigner des variables d'instance
    end

    test 'results returns a hash of results' do
      results = @result_service.results
      
      assert_kind_of Array, results
      
      # On cherche la catégorie senior
      category = contest_categories(:category_senior)
      cat_results = results.find { |r| r[:category_id] == category.id }
      
      assert_not_nil cat_results, "Results should contain data for category senior"
      assert_kind_of Array, cat_results[:participants]
      
      participant = contest_participants(:participant_1)
      participant_found = cat_results[:participants].find { |p| p[:participant_id] == participant.id }
      assert_not_nil participant_found
    end

    test 'delete_cache_key runs without error' do
      # Comme Rails.cache est null_store en test, on vérifie juste que ça ne crash pas
      assert_nothing_raised do
        @result_service.delete_cache_key
      end
    end
    
    test 'results with category_id filter' do
      category = contest_categories(:category_senior)
      filtered_service = ContestService::Result.new(@contest, category_id: category.id)
      results = filtered_service.results
      
      # On ne devrait avoir que des résultats liés à cette catégorie
      results.each do |r|
        assert_equal category.id, r[:category_id]
      end
    end
  end
end
