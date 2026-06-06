# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Outdoor
    class CragFilteredAscentsTest < ActiveSupport::TestCase
      setup do
        @user = users(:normal_user)
      end

      test 'initializes with default filters' do
        filtered_ascents = CragFilteredAscents.new(@user, {})
        
        # On vérifie que les ascents sont chargés (même si c'est vide selon les fixtures, la relation doit exister)
        assert_not_nil filtered_ascents.ascents
      end

      test 'filters by ascent_status' do
        params = { ascent_filter: ['sent'] }
        filtered_ascents = CragFilteredAscents.new(@user, params)
        
        # On vérifie que les ascents retournés sont bien filtrés
        # On s'attend à ce qu'il y en ait au moins un si les fixtures sont bien chargées
        assert filtered_ascents.ascents.all? { |a| a.ascent_status == 'sent' }
      end
    end
  end
end
