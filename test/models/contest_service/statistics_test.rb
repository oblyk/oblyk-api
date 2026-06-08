# frozen_string_literal: true

require 'test_helper'

module ContestService
  class StatisticsTest < ActiveSupport::TestCase
    setup do
      @contest = contests(:contest_1)
      @stats_service = ContestService::Statistics.new(@contest)
    end

    test 'participants_figure returns correct figures' do
      figures = @stats_service.participants_figure

      assert_not_nil figures[:total]
      assert_not_nil figures[:female]
      assert_not_nil figures[:male]
      assert_not_nil figures[:with_ascents]
      assert_not_nil figures[:participation]
    end

    test 'by_ages returns age distribution' do
      stats = @stats_service.by_ages

      if stats
        assert_kind_of Array, stats[:ages]
        assert_kind_of BigDecimal, stats[:average]
      else
        assert_not stats
      end
    end

    test 'ascents_by_steps returns structured statistics' do
      stats = @stats_service.ascents_by_steps

      assert_kind_of Array, stats
      assert_not_empty stats
      assert_equal 'Qualifications', stats.first[:name]
      assert_not_empty stats.first[:steps]
    end

    test 'initialize with category_id' do
      category = contest_categories(:category_senior)
      stats_service = ContestService::Statistics.new(@contest, category_id: category.id)
      figures = stats_service.participants_figure

      assert_equal @contest.contest_participants.where(contest_category_id: category.id).count, figures[:total]
    end
  end
end
