# frozen_string_literal: true

require 'test_helper'

class AscentUserTest < ActiveSupport::TestCase
  setup do
    @ascent_user = AscentUser.new(
      user: users(:normal_user),
      ascent: ascents(:ascent_user_two)
    )
  end

  test 'ascent_user is valid' do
    assert @ascent_user.valid?
  end

  test 'ascent_user is invalid without user' do
    @ascent_user.user = nil
    assert_not @ascent_user.valid?
  end

  test 'ascent_user is invalid without ascent' do
    @ascent_user.ascent = nil
    assert_not @ascent_user.valid?
  end

  test 'ascent_user is invalid if user already has this ascent' do
    duplicate_ascent_user = AscentUser.new(
      user: users(:normal_user),
      ascent: ascents(:ascent_user_one)
    )
    assert_not duplicate_ascent_user.valid?
    assert_includes duplicate_ascent_user.errors[:ascent], 'is_already_taken'
  end
end
