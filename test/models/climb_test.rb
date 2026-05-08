# frozen_string_literal: true

require 'test_helper'

class ClimbTest < ActiveSupport::TestCase
  test 'Climb::ALL_LIST is an array' do
    assert Climb::ALL_LIST.is_a?(Array)
  end

  test 'Climb::ALL_LIST contains expected values' do
    expected_anchors = %w[
      sport_climbing
      bouldering
      multi_pitch
      trad_climbing
      aid_climbing
      deep_water
      via_ferrata
      pan
      speed_climbing
    ]
    assert_equal expected_anchors.sort, Climb::ALL_LIST.sort
  end

  test 'Climb::ALL_LIST is frozen' do
    assert Climb::ALL_LIST.frozen?
  end

  test 'Climb::ALL_LIST has 9 elements' do
    assert_equal 9, Climb::ALL_LIST.size
  end

  test 'should sport_climbing route be single_pitch?' do
    assert Climb.single_pitch?('sport_climbing')
  end

  test 'should multi_pitch route be boltable?' do
    assert Climb.boltable?('multi_pitch')
  end

  test 'should trad_climbing route be anchorable?' do
    assert Climb.anchorable?('trad_climbing')
  end

  test 'should aid_climbing route be ropable?' do
    assert Climb.ropable?('aid_climbing')
  end

  test 'should bouldering route be startable?' do
    assert Climb.startable?('bouldering')
  end

  test 'should bouldering route be receptionable?' do
    assert Climb.receptionable?('bouldering')
  end
end
