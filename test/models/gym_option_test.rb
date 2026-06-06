# frozen_string_literal: true

require 'test_helper'

class GymOptionTest < ActiveSupport::TestCase
  setup do
    @gym_option = gym_options(:api_option)
  end

  test 'gym_option is valid' do
    assert @gym_option.valid?
  end

  test 'gym_option is invalid with wrong option_type' do
    @gym_option.option_type = 'wrong_type'
    assert_not @gym_option.valid?
  end

  test 'gym_option is invalid without start_date' do
    @gym_option.start_date = nil
    assert_not @gym_option.valid?
  end

  test 'activated? returns true if current date is between start and end date' do
    assert gym_options(:api_option).activated?
    assert_not gym_options(:expired_option).activated?
    assert_not gym_options(:future_option).activated?
  end

  test 'credited? returns true for non-contest options' do
    assert gym_options(:api_option).credited?
  end

  test 'credited? returns true for contest with remaining units' do
    assert gym_options(:contest_option).credited?
  end

  test 'credited? returns false for contest without remaining units' do
    assert_not gym_options(:no_credit_contest).credited?
  end

  test 'usable? returns true if activated and credited' do
    assert gym_options(:api_option).usable?
    assert_not gym_options(:expired_option).usable?
    assert_not gym_options(:no_credit_contest).usable?
  end

  test 'summary_to_json returns correct keys' do
    summary = @gym_option.summary_to_json
    assert_equal %i[option_type start_date end_date remaining_unit unlimited_unit activated credited usable], summary.keys
  end

  test 'delete_gym_cache is called after save' do
    gym = gyms(:my_gym)
    option = GymOption.new(
      gym: gym,
      option_type: GymOption::OPTION_API,
      start_date: Date.current
    )

    assert option.save
  end
end
