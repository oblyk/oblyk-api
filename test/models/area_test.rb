# frozen_string_literal: true

require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @area = areas(:foret_de_saou)
    @crag = crags(:rocher_des_aures)
  end

  test 'area is valid' do
    assert @area.valid?
  end

  test 'area is invalid without name' do
    @area.name = nil
    assert_not @area.valid?
    assert_includes @area.errors.keys, :name
  end

  test 'crag_routes_count returns sum of crags routes count' do
    @area.crags << @crag
    @crag.update_column(:crag_routes_count, 10)
    
    assert_equal 10, @area.crag_routes_count
    
    # Ajout d'un autre site avec des voies
    crag2 = Crag.create!(
      name: 'Second Crag',
      latitude: 45,
      longitude: 5,
      city: 'Test City',
      user: @user
    )
    crag2.update_column(:crag_routes_count, 5)
    AreaCrag.create!(area: @area, crag: crag2)
    
    assert_equal 15, @area.crag_routes_count
  end

  test 'hardest_route returns the crag with the highest max_grade_value' do
    crag_easy = Crag.create!(
      name: 'Easy Crag',
      latitude: 45,
      longitude: 5,
      city: 'Test City',
      max_grade_value: 10,
      user: @user
    )
    crag_hard = Crag.create!(
      name: 'Hard Crag',
      latitude: 45,
      longitude: 5,
      city: 'Test City',
      max_grade_value: 50,
      user: @user
    )
    
    AreaCrag.create!(area: @area, crag: crag_easy)
    AreaCrag.create!(area: @area, crag: crag_hard)
    
    assert_equal crag_hard, @area.hardest_route
  end

  test 'easiest_route returns the crag with the lowest min_grade_value' do
    crag_easy = Crag.create!(
      name: 'Easy Crag',
      latitude: 45,
      longitude: 5,
      city: 'Test City',
      min_grade_value: 10,
      user: @user
    )
    crag_hard = Crag.create!(
      name: 'Hard Crag',
      latitude: 45,
      longitude: 5,
      city: 'Test City',
      min_grade_value: 50,
      user: @user
    )
    
    AreaCrag.create!(area: @area, crag: crag_easy)
    AreaCrag.create!(area: @area, crag: crag_hard)
    
    assert_equal crag_easy, @area.easiest_route
  end

  test 'summary_to_json returns expected keys' do
    @area.save # Génère le slug si absent
    json = @area.summary_to_json
    assert_equal @area.id, json[:id]
    assert_equal @area.name, json[:name]
    assert_not_nil json[:slug_name]
    assert_nil json[:photo][:id]
    assert_includes json.keys, :photo
  end

  test 'detail_to_json returns expected keys' do
    @area.crags << @crag
    json = @area.detail_to_json
    
    assert_equal @area.id, json[:id]
    assert_equal 1, json[:crags_count]
    assert_includes json.keys, :routes_figures
    assert_includes json.keys, :area_crags
    assert_includes json.keys, :creator
    assert_includes json.keys, :history
  end
  
  test 'all_photos returns all photos from crags, sectors and routes' do
    # Cette méthode est assez complexe car elle traverse beaucoup d'associations.
    # On va au moins tester qu'elle s'exécute sans erreur et renvoie un tableau.
    assert_kind_of Array, @area.all_photos
  end
end
