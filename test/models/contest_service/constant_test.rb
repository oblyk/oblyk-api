# frozen_string_literal: true

require 'test_helper'

module ContestService
  class ConstantTest < ActiveSupport::TestCase
    test 'RANKING_TYPE_LIST contains expected types' do
      assert_includes ContestService::Constant::RANKING_TYPE_LIST, 'division'
      assert_includes ContestService::Constant::RANKING_TYPE_LIST, 'fixed_points'
    end

    test 'RANKING_UNITS has expected units for division' do
      assert_equal %w[pts], ContestService::Constant::RANKING_UNITS['division']
    end

    test 'COMBINED_RANKING_TYPE_LIST contains expected types' do
      assert_includes ContestService::Constant::COMBINED_RANKING_TYPE_LIST, 'addition'
      assert_includes ContestService::Constant::COMBINED_RANKING_TYPE_LIST, 'decrement_points'
    end

    test 'COMBINED_RANKING_POINT_MATRIX has 30 values' do
      assert_equal 30, ContestService::Constant::COMBINED_RANKING_POINT_MATRIX.size
      assert_equal 100, ContestService::Constant::COMBINED_RANKING_POINT_MATRIX.first
      assert_equal 1, ContestService::Constant::COMBINED_RANKING_POINT_MATRIX.last
    end
  end
end
