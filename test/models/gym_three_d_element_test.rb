# frozen_string_literal: true

require 'test_helper'

class GymThreeDElementTest < ActiveSupport::TestCase
  setup do
    @gym_three_d_element = gym_three_d_elements(:element_1)
  end

  test 'gym_three_d_element is valid' do
    assert @gym_three_d_element.valid?
  end

  test 'summary_to_json returns correct keys' do
    summary = @gym_three_d_element.summary_to_json
    assert_equal @gym_three_d_element.id, summary[:id]
    assert_equal @gym_three_d_element.gym_id, summary[:gym_id]
    assert_includes summary.keys, :gym_three_d_asset
    assert_includes summary.keys, :three_d_position
  end

  test 'detail_to_json returns same as summary_to_json' do
    assert_equal @gym_three_d_element.summary_to_json, @gym_three_d_element.detail_to_json
  end
end
