# frozen_string_literal: true

require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  test 'clean_grade returns cleaned grade' do
    assert_equal '6a', Grade.clean_grade(' 6A ')
    assert_equal '6a/6a+', Grade.clean_grade('6A/6A+')
    assert_equal '5.10a', Grade.clean_grade('5.10A')
    assert_equal 'B12', Grade.clean_grade('b12')
    assert_equal 'V10', Grade.clean_grade('v10')
    assert_nil Grade.clean_grade(nil)
  end

  test 'valid? validates grades' do
    assert Grade.valid?('6a')
    assert Grade.valid?('6a+')
    assert Grade.valid?('7b+')
    assert Grade.valid?('7b/7c')
    assert Grade.valid?('5.10a')
    assert Grade.valid?('B12')
    assert Grade.valid?('V10')
    assert Grade.valid?('PD')
    assert Grade.valid?('IV')
    assert Grade.valid?('?')
    
    assert_not Grade.valid?('invalid')
    assert_not Grade.valid?('')
    assert_not Grade.valid?(nil)
  end

  test 'to_value converts grade to numeric value' do
    assert_equal 1, Grade.to_value('1a')
    assert_equal 31, Grade.to_value('6a')
    assert_equal 32, Grade.to_value('6a+')
    assert_equal 54, Grade.to_value('9c+')
    assert_equal 0, Grade.to_value('?')
    assert_nil Grade.to_value(nil)
  end

  test 'grade_color returns expected color' do
    # value for 6a is 31. value_color(31) is GRADES_COLOR[32]
    expected_color = Grade.value_color(31)
    assert_equal expected_color, Grade.grade_color('6a')
  end

  test 'value_color returns expected color from value' do
    assert_equal 'rgb(255,85,220)', Grade.value_color(-1) # index 0
    assert_equal 'rgb(246,68,211)', Grade.value_color(0)  # index 1
  end

  test 'degree returns degree string' do
    assert_equal '1', Grade.degree(1)
    assert_equal '1', Grade.degree(6)
    assert_equal '2', Grade.degree(7)
    assert_equal '6', Grade.degree(31)
    assert_equal '9', Grade.degree(54)
  end

  test 'level returns level string' do
    assert_equal '1a', Grade.level(1)
    assert_equal '1a', Grade.level(2)
    assert_equal '6a', Grade.level(31)
    assert_equal '9c', Grade.level(54)
  end

  test 'degree_colors returns array of colors' do
    colors = Grade.degree_colors
    assert colors.is_a?(Array)
    assert_equal Grade::GRADES_COLOR.size / 2, colors.size
    assert_equal Grade::GRADES_COLOR[0], colors[0]
    assert_equal Grade::GRADES_COLOR[2], colors[1]
  end

  test 'range_values returns expected ranges' do
    assert_equal (0..53), Grade.range_values(:french)
    assert Grade.range_values(:usa_lead).is_a?(Array)
    assert_includes Grade.range_values(:usa_lead), 31 # 6a
  end
end
