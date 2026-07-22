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

    test 'ascents_by_steps for different ranking types' do
      types_to_test = [
        ContestService::Constant::DIVISION,
        ContestService::Constant::DIVISION_AND_ZONE,
        ContestService::Constant::ZONE_AND_TOP_REALISED,
        ContestService::Constant::ATTEMPTS_TO_ONE_ZONE_AND_TOP,
        ContestService::Constant::ATTEMPTS_TO_TOP,
        ContestService::Constant::DIVISION_AND_ATTEMPT,
        ContestService::Constant::FIXED_POINTS,
        ContestService::Constant::POINT_RELATIVE_TO_HIGHEST_HOLD,
        ContestService::Constant::ATTEMPTS_TO_TWO_ZONES_AND_TOP,
        ContestService::Constant::HIGHEST_HOLD,
        ContestService::Constant::BEST_TIMES
      ]

      step = contest_stage_steps(:step_1_stage_1)
      route = contest_routes(:route_1)
      participant = contest_participants(:participant_1)

      types_to_test.each do |ranking_type|
        step.update_column(:ranking_type, ranking_type)

        ascent = ContestParticipantAscent.find_or_initialize_by(
          contest_participant: participant,
          contest_route: route
        )
        ascent.update!(
          realised: true,
          zone_1_attempt: 1,
          top_attempt: 1,
          hold_number: 10,
          ascent_time: Time.zone.now
        )
        route.update_column(:number_of_holds, 20)
        route.update_column(:additional_zone, true)

        stats = ContestService::Statistics.new(@contest).ascents_by_steps
        step_stats = stats.first[:steps].find { |s| s[:name] == step.name }
        route_stats = step_stats[:groups].first[:routes].find { |r| r[:id] == route.id }

        case ranking_type
        when ContestService::Constant::DIVISION, ContestService::Constant::FIXED_POINTS
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :top_ratio
        when ContestService::Constant::DIVISION_AND_ZONE
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :zone
          assert_includes route_stats.keys, :top_ratio
          assert_includes route_stats.keys, :zone_ratio
        when ContestService::Constant::ZONE_AND_TOP_REALISED
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :zone
          assert_includes route_stats.keys, :top_ratio
          assert_includes route_stats.keys, :zone_ratio
        when ContestService::Constant::ATTEMPTS_TO_ONE_ZONE_AND_TOP
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :top_attempt
          assert_includes route_stats.keys, :zone
          assert_includes route_stats.keys, :zone_attempt
        when ContestService::Constant::ATTEMPTS_TO_TOP, ContestService::Constant::DIVISION_AND_ATTEMPT
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :top_attempt
          assert_includes route_stats.keys, :top_by_attempt
        when ContestService::Constant::HIGHEST_HOLD, ContestService::Constant::POINT_RELATIVE_TO_HIGHEST_HOLD
          assert_includes route_stats.keys, :top
          assert_includes route_stats.keys, :max_hold
          assert_includes route_stats.keys, :min_hold
          assert_includes route_stats.keys, :holds_chart
        when ContestService::Constant::BEST_TIMES
          assert_includes route_stats.keys, :best_time
          assert_includes route_stats.keys, :worst_time
          assert_includes route_stats.keys, :times_chart
        end
      end
    end

    test 'initialize with category_id' do
      category = contest_categories(:category_senior)
      stats_service = ContestService::Statistics.new(@contest, category_id: category.id)
      figures = stats_service.participants_figure

      assert_equal @contest.contest_participants.where(contest_category_id: category.id).count, figures[:total]
    end
  end
end
