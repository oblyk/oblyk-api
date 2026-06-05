# frozen_string_literal: true

require 'test_helper'

class GymClimbingStyleTest < ActiveSupport::TestCase
  setup do
    @gym_climbing_style = gym_climbing_styles(:one)
  end

  test 'valid gym climbing style' do
    assert @gym_climbing_style.valid?
  end

  test 'invalid without style' do
    @gym_climbing_style.style = nil
    assert_not @gym_climbing_style.valid?
  end

  test 'invalid without climbing_type' do
    @gym_climbing_style.climbing_type = nil
    assert_not @gym_climbing_style.valid?
  end

  test 'invalid with wrong climbing_type' do
    @gym_climbing_style.climbing_type = 'invalid'
    assert_not @gym_climbing_style.valid?
  end

  test 'invalid with wrong style' do
    @gym_climbing_style.style = 'invalid'
    assert_not @gym_climbing_style.valid?
  end

  test 'summary_to_json returns expected keys' do
    json = @gym_climbing_style.summary_to_json
    assert_equal @gym_climbing_style.id, json[:id]
    assert_equal @gym_climbing_style.style, json[:style]
    assert_equal @gym_climbing_style.climbing_type, json[:climbing_type]
    assert_equal @gym_climbing_style.color, json[:color]
    assert_equal @gym_climbing_style.gym_id, json[:gym_id]
  end

  test 'detail_to_json returns expected keys' do
    json = @gym_climbing_style.detail_to_json
    assert json.key?(:history)
    assert json[:history].key?(:created_at)
    assert json[:history].key?(:updated_at)
  end
end
