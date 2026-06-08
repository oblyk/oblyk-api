# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Indoor
    class ChartTest < ActiveSupport::TestCase
      setup do
        @user = users(:normal_user)
        @ascent = ascent_gym_routes(:gym_ascent_one)
      end

      test 'grade returns correct structure' do
        ascents = [@ascent]
        chart_data = Chart.grade(ascents)

        assert chart_data.key?(:datasets)
        assert chart_data.key?(:labels)
        assert_equal 1, chart_data[:datasets][0][:data].sum
      end

      test 'by_levels returns correct structure' do
        line = color_system_lines(:line_1_1)
        @ascent.update_column(:color_system_line_id, line.id)

        ascents = [@ascent]
        charts = Chart.by_levels(ascents)

        assert_kind_of Array, charts
        assert_equal 1, charts.size
        assert_equal 'level_chart', charts[0][:type]
        assert charts[0].key?(:color_system)
        assert charts[0].key?(:chart)
      end

      test 'climb_type returns correct structure' do
        chart = Chart.new(@user)
        chart_data = chart.climb_type

        assert chart_data.key?(:datasets)
        assert_equal %w[sport_climbing bouldering pan], chart_data[:labels]
        assert_equal 1, chart_data[:datasets][0][:data][1]
      end

      test 'years returns correct structure' do
        chart = Chart.new(@user)
        chart_data = chart.years

        assert chart_data.key?(:datasets)
        assert_includes chart_data[:labels], @ascent.released_at.year
      end

      test 'months returns correct structure' do
        chart = Chart.new(@user)
        chart_data = chart.months

        assert chart_data.key?(:datasets)
        assert_includes chart_data[:labels], @ascent.released_at.strftime('%Y-%m')
      end
    end
  end
end
