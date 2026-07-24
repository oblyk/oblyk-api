# frozen_string_literal: true

require 'test_helper'

class GymLabelFontTest < ActiveSupport::TestCase
  test 'GymLabelFont::FONTS is a hash' do
    assert_kind_of Hash, GymLabelFont::FONTS
  end

  test 'GymLabelFont::FONTS is frozen' do
    assert_predicate GymLabelFont::FONTS, :frozen?
  end

  test 'GymLabelFont::FONTS contains expected keys' do
    expected_keys = %i[
      lato
      overpass
      raleway
      roboto_serif
      yeseva_one
      shadows_into_light
      sue_ellen_francisco
      unbounded
      black_ops_one
    ]

    assert_equal expected_keys.sort, GymLabelFont::FONTS.keys.sort
  end

  test 'each font in GymLabelFont::FONTS has required attributes' do
    GymLabelFont::FONTS.each_value do |font|
      assert font.key?(:name)
      assert font.key?(:query)
      assert font.key?(:ref)
      assert font.key?(:size)
      assert font.key?(:line_height)
      assert font.key?(:svg_preview)
    end
  end

  test 'each font svg_preview is a string starting with <svg' do
    GymLabelFont::FONTS.each_value do |font|
      assert_kind_of String, font[:svg_preview]
      assert font[:svg_preview].start_with?('<svg')
    end
  end
end
