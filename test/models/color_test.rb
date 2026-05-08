# frozen_string_literal: true

require 'test_helper'

class ColorTest < ActiveSupport::TestCase
  test 'hex_to_rgb converts hex to rgb array' do
    assert_equal [255, 255, 255], Color.hex_to_rgb('#ffffff')
    assert_equal [0, 0, 0], Color.hex_to_rgb('#000000')
    assert_equal [255, 0, 0], Color.hex_to_rgb('#ff0000')
    assert_equal [0, 255, 0], Color.hex_to_rgb('#00ff00')
    assert_equal [0, 0, 255], Color.hex_to_rgb('#0000ff')
  end

  test 'hex_to_rgb works without hash' do
    assert_equal [255, 255, 255], Color.hex_to_rgb('ffffff')
  end

  test 'black_or_white_rgb returns inherit when color is inherit' do
    assert_equal 'inherit', Color.black_or_white_rgb('inherit')
  end

  test 'black_or_white_rgb returns black for light hex colors' do
    assert_equal 'rgb(0,0,0)', Color.black_or_white_rgb('#ffffff') # Blanc
    assert_equal 'rgb(0,0,0)', Color.black_or_white_rgb('#ffff00') # Jaune
  end

  test 'black_or_white_rgb returns white for dark hex colors' do
    assert_equal 'rgb(255,255,255)', Color.black_or_white_rgb('#000000') # Noir
    assert_equal 'rgb(255,255,255)', Color.black_or_white_rgb('#333333') # Gris foncé
  end

  test 'black_or_white_rgb returns black for light rgb colors' do
    assert_equal 'rgb(0,0,0)', Color.black_or_white_rgb('rgb(255, 255, 255)')
    assert_equal 'rgb(0,0,0)', Color.black_or_white_rgb('rgb(240, 240, 240)')
  end

  test 'black_or_white_rgb returns white for dark rgb colors' do
    assert_equal 'rgb(255,255,255)', Color.black_or_white_rgb('rgb(0, 0, 0)')
    assert_equal 'rgb(255,255,255)', Color.black_or_white_rgb('rgb(50, 50, 50)')
  end
end
