# frozen_string_literal: true

require 'test_helper'

class AscentGymRouteTest < ActiveSupport::TestCase
  setup do
    @ascent = ascent_gym_routes(:gym_ascent_one)
  end

  test 'ascent_gym_route is valid' do
    assert @ascent.valid?
  end

  test 'ascent_gym_route is invalid with wrong climbing_type' do
    @ascent.climbing_type = 'wrong_type'
    assert_not @ascent.valid?
  end

  test 'normalize_roping_status' do
    @ascent.ascent_status = 'project'
    @ascent.roping_status = 'lead_climb'
    @ascent.valid?
    assert_nil @ascent.roping_status
  end

  test 'points calculation' do
    # On mocke un peu pour tester la logique de points si possible, 
    # ou au moins vérifier que la méthode existe et retourne une structure attendue.
    # Note: points() dépend de gym_route.calculated_point et gym.ascents_multiplier
    
    # Pour l'instant on vérifie que la méthode retourne nil si pas de gym_route
    @ascent.gym_route = nil
    assert_nil @ascent.points
  end
end
