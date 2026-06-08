# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Outdoor
    class ChartTest < ActiveSupport::TestCase
      setup do
        @ascent1 = ascent_crag_routes(:crag_ascent_one)
        @ascent2 = ascent_crag_routes(:crag_ascent_project)
        @ascents = [@ascent1, @ascent2]
        @chart = Chart.new(@ascents)
      end

      test 'climb_type returns correct structure' do
        data = @chart.climb_type
        assert_includes data.keys, :datasets
        assert_includes data.keys, :labels
        assert_equal Climb::CRAG_LIST, data[:labels]
      end

      test 'grade returns correct structure' do
        data = @chart.grade
        assert_includes data.keys, :datasets
        assert_includes data.keys, :labels
        assert_equal 27, data[:labels].size
      end

      test 'years returns correct structure' do
        data = @chart.years
        assert_includes data.keys, :datasets
        assert_includes data.keys, :labels
      end

      test 'months returns correct structure' do
        data = @chart.months
        assert_includes data.keys, :datasets
        assert_includes data.keys, :labels
      end

      test 'evolution_by_year returns correct structure' do
        data = @chart.evolution_by_year
        assert_includes data.keys, :datasets
        assert_includes data.keys, :labels
      end
    end
  end
end
