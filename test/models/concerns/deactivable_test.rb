# frozen_string_literal: true

require 'test_helper'

class DeactivableTest < ActiveSupport::TestCase
  setup do
    @opener = gym_openers(:opener_one)
  end

  test 'activated scope returns only activated objects' do
    @opener.activate!
    assert_includes GymOpener.activated, @opener

    @opener.deactivate!
    assert_not_includes GymOpener.activated, @opener
  end

  test 'deactivated scope returns only deactivated objects' do
    @opener.deactivate!
    assert_includes GymOpener.deactivated, @opener

    @opener.activate!
    assert_not_includes GymOpener.deactivated, @opener
  end

  test 'deactivate! sets deactivated_at' do
    assert_nil @opener.deactivated_at
    @opener.deactivate!
    assert_not_nil @opener.deactivated_at
  end

  test 'activate! clears deactivated_at' do
    @opener.deactivate!
    assert_not_nil @opener.deactivated_at
    @opener.activate!
    assert_nil @opener.deactivated_at
  end

  test 'deactivated? returns true if deactivated_at is present and in the past' do
    @opener.deactivated_at = 1.day.ago
    assert @opener.deactivated?

    @opener.deactivated_at = nil
    assert_not @opener.deactivated?

    @opener.deactivated_at = 1.day.from_now
    assert_not @opener.deactivated?
  end

  test 'activated? returns true if not deactivated' do
    @opener.deactivated_at = nil
    assert @opener.activated?

    @opener.deactivated_at = 1.day.ago
    assert_not @opener.activated?
  end
end
