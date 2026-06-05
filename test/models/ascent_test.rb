# frozen_string_literal: true

require 'test_helper'

class AscentTest < ActiveSupport::TestCase
  setup do
    @ascent = Ascent.new(
      user: users(:normal_user),
      released_at: Date.current,
      ascent_status: 'sent'
    )
  end

  test 'ascent is valid' do
    assert @ascent.valid?
  end

  test 'ascent is invalid without user' do
    @ascent.user = nil
    assert_not @ascent.valid?
  end

  test 'ascent is invalid without released_at' do
    @ascent.released_at = nil
    assert_not @ascent.valid?
  end

  test 'ascent is invalid with wrong ascent_status' do
    @ascent.ascent_status = 'wrong_status'
    assert_not @ascent.valid?
  end

  test 'hardness_value returns correct values' do
    @ascent.hardness_status = 'easy_for_the_grade'
    assert_equal(-1, @ascent.hardness_value)

    @ascent.hardness_status = 'this_grade_is_accurate'
    assert_equal 0, @ascent.hardness_value

    @ascent.hardness_status = 'sandbagged'
    assert_equal 1, @ascent.hardness_value
  end

  test 'sections_done returns correct indexes' do
    @ascent.sections = [{ 'index' => 0 }, { 'index' => 2 }]
    assert_equal [0, 2], @ascent.sections_done
  end

  test 'made scope returns only made ascents' do
    @ascent.save!
    assert_includes Ascent.made, @ascent
  end

  test 'project scope returns only projects' do
    @ascent.ascent_status = 'project'
    @ascent.save!
    assert_includes Ascent.project, @ascent
  end
end
