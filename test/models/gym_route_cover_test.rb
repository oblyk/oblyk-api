# frozen_string_literal: true

require 'test_helper'

class GymRouteCoverTest < ActiveSupport::TestCase
  setup do
    @gym_route_cover = gym_route_covers(:cover_one)
  end

  test 'gym_route_cover is valid' do
    assert @gym_route_cover.valid?
  end

  test 'summary_to_json returns a hash' do
    summary = @gym_route_cover.summary_to_json
    assert_kind_of Hash, summary
    assert_equal @gym_route_cover.id, summary[:id]
  end

  test 'detail_to_json returns a hash with history' do
    detail = @gym_route_cover.detail_to_json
    assert_kind_of Hash, detail
    assert detail.key?(:history)
  end

  test 'original_file_path returns nil if no picture' do
    assert_nil @gym_route_cover.original_file_path
  end
end
