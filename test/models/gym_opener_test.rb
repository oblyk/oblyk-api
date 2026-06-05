# frozen_string_literal: true

require 'test_helper'

class GymOpenerTest < ActiveSupport::TestCase
  setup do
    @opener = gym_openers(:opener_one)
  end

  test 'gym_opener is valid' do
    assert @opener.valid?
  end

  test 'gym_opener is invalid without name' do
    @opener.name = nil
    assert_not @opener.valid?
  end

  test 'summary_to_json returns expected structure' do
    json = @opener.summary_to_json
    assert_equal @opener.id, json[:id]
    assert_equal @opener.name, json[:name]
    assert_equal @opener.gym_id, json[:gym][:id]
    assert_not_nil json[:user] if @opener.user
  end

  test 'detail_to_json returns expected structure' do
    json = @opener.detail_to_json
    assert_equal @opener.id, json[:id]
    assert_nil json[:email]
    assert_not_nil json[:history][:created_at]
  end
end
