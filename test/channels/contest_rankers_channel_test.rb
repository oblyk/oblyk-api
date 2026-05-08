# frozen_string_literal: true

require 'test_helper'

class ContestRankersChannelTest < ActionCable::Channel::TestCase
  setup do
    @gym = gyms(:my_gym)
    @contest = Contest.create!(
      gym: @gym,
      name: 'Test Contest',
      start_date: Date.current,
      end_date: Date.current + 1.day,
      subscription_start_date: Date.current - 7.days,
      subscription_end_date: Date.current - 1.day,
      categorization_type: 'custom'
    )
  end

  test 'subscribes to a contest rankers stream' do
    subscribe contest_id: @contest.id
    assert_has_stream "contest_rankers_#{@contest.id}"
  end

  test 'does not subscribe to a contest rankers stream with invalid contest_id' do
    assert_raises ActiveRecord::RecordNotFound do
      subscribe contest_id: 'invalid_id'
    end
  end

  test 'unsubscribed stops all streams' do
    subscribe contest_id: @contest.id
    assert_has_stream "contest_rankers_#{@contest.id}"

    unsubscribe
    assert_no_streams
  end
end
