# frozen_string_literal: true

require 'test_helper'

class IpBlackListTest < ActiveSupport::TestCase
  test 'initialize dates before validation' do
    ip_black_list = IpBlackList.new(ip: '1.1.1.1')
    assert_nil ip_black_list.blocked_at
    assert_nil ip_black_list.block_expired_at

    ip_black_list.validate
    assert_not_nil ip_black_list.blocked_at
    assert_not_nil ip_black_list.block_expired_at
    assert_equal 30, ((ip_black_list.block_expired_at - ip_black_list.blocked_at) / 60).round
  end

  test 'blocked! method updates attributes' do
    ip_black_list = ip_black_lists(:one)
    old_count = ip_black_list.block_count
    params = { foo: 'bar' }

    ip_black_list.blocked!(params)

    assert_equal old_count + 1, ip_black_list.block_count
    assert_equal params.to_s, ip_black_list.params_sent
    assert_in_delta Time.current, ip_black_list.blocked_at, 2.seconds
    assert_in_delta Time.current + 30.minutes, ip_black_list.block_expired_at, 2.seconds
  end

  test 'currently_blocked scope' do
    blocked = IpBlackList.currently_blocked
    assert_includes blocked, ip_black_lists(:two)
    assert_not_includes blocked, ip_black_lists(:one)
  end
end
