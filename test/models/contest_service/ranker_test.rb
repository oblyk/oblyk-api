# frozen_string_literal: true

require 'test_helper'

module ContestService
  class RankerTest < ActiveSupport::TestCase
    setup do
      @step = contest_stage_steps(:step_1_stage_1)
      @category = contest_categories(:category_senior)
      @genre = 'male'
      @route = contest_routes(:route_1)
      @participant = contest_participants(:participant_1)
    end

    test 'initialize sets correct attributes' do
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      assert_equal @step, ranker.step
      assert_equal @category, ranker.category
      assert_equal @genre, ranker.genre
    end

    test 'initialize filters ascents by genre if not unisex' do
      @category.update_column(:unisex, false)
      ContestParticipantAscent.delete_all
      ContestParticipantAscent.create!(contest_participant: @participant, contest_route: @route, realised: true) # male
      ContestParticipantAscent.create!(contest_participant: contest_participants(:participant_2), contest_route: @route, realised: true) # female

      ranker = ContestService::Ranker.new(@step, @category, 'male')
      assert ranker.ascents.all? { |a| a.contest_participant.genre == 'male' }
    end

    test 'initialize does not filter by genre if unisex' do
      @category.update_column(:unisex, true)
      ranker = ContestService::Ranker.new(@step, @category, 'male')
      assert ranker.unisex
    end

    test 'scores for DIVISION' do
      @step.update_column(:ranking_type, Constant::DIVISION)
      ContestParticipantAscent.delete_all
      ascent1 = ContestParticipantAscent.create!(contest_participant: @participant, contest_route: @route, realised: true)
      ascent2 = ContestParticipantAscent.create!(contest_participant: contest_participants(:participant_1), contest_route: @route, realised: true)
      other_male = ContestParticipant.new(
        first_name: 'Other', last_name: 'Male', genre: 'male', 
        contest: @participant.contest, contest_category: @category,
        token: 'other.male',
        date_of_birth: 20.years.ago,
        email: 'other@male.com'
      )
      other_male.save(validate: false)
      ascent2.update!(contest_participant: other_male)

      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      score = ranker.scores(ascent1)
      assert_equal 500, score[:value]
      assert_equal [500], score[:details]
    end

    test 'scores for DIVISION_AND_ZONE' do
      @step.update_column(:ranking_type, Constant::DIVISION_AND_ZONE)
      ContestParticipantAscent.delete_all
      ascent = ContestParticipantAscent.create!(
        contest_participant: @participant, 
        contest_route: @route, 
        realised: true,
        top_attempt: 1,
        zone_1_attempt: 1
      )
      
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      score = ranker.scores(ascent)
      assert_equal 1000, score[:value]
      
      ascent_zone = ContestParticipantAscent.create!(
        contest_participant: @participant,
        contest_route: contest_routes(:route_2),
        realised: false,
        top_attempt: 0,
        zone_1_attempt: 1
      )
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      score_zone = ranker.scores(ascent_zone)
      assert_equal 0.5, score_zone[:value]
      assert_equal [0, true], score_zone[:details]
    end

    test 'scores for DIVISION_AND_ATTEMPT' do
      @step.update_column(:ranking_type, Constant::DIVISION_AND_ATTEMPT)
      ContestParticipantAscent.delete_all
      ascent = ContestParticipantAscent.create!(
        contest_participant: @participant, 
        contest_route: @route, 
        realised: true,
        top_attempt: 2
      )
      
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      score = ranker.scores(ascent)
      assert_equal 999.998, score[:value]
      assert_equal [1000, 2], score[:details]
    end

    test 'scores for FIXED_POINTS' do
      @step.update_column(:ranking_type, Constant::FIXED_POINTS)
      @route.update_column(:fixed_points, 500)
      ascent = ContestParticipantAscent.create!(contest_participant: @participant, contest_route: @route, realised: true)
      
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      score = ranker.scores(ascent)
      assert_equal 500, score[:value]
    end

    test 'scores for ATTEMPTS_TO_TOP' do
      @step.update_column(:ranking_type, Constant::ATTEMPTS_TO_TOP)
      ascent = ContestParticipantAscent.new(top_attempt: 1)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      score = ranker.scores(ascent)
      assert_equal 10, score[:value]
      
      ascent.top_attempt = 3
      score = ranker.scores(ascent)
      assert_equal 8, score[:value]
    end

    test 'scores for ZONE_AND_TOP_REALISED' do
      @step.update_column(:ranking_type, Constant::ZONE_AND_TOP_REALISED)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      ascent = ContestParticipantAscent.new(top_attempt: 1, zone_1_attempt: 1)
      assert_equal 1.001, ranker.scores(ascent)[:value]
      
      ascent = ContestParticipantAscent.new(top_attempt: 0, zone_1_attempt: 1)
      assert_equal 0.001, ranker.scores(ascent)[:value]
    end

    test 'scores for ATTEMPTS_TO_ONE_ZONE_AND_TOP' do
      @step.update_column(:ranking_type, Constant::ATTEMPTS_TO_ONE_ZONE_AND_TOP)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      ascent = ContestParticipantAscent.new(top_attempt: 1, zone_1_attempt: 1)
      assert_equal 1000.899, ranker.scores(ascent)[:value]
    end

    test 'scores for HIGHEST_HOLD' do
      @step.update_column(:ranking_type, Constant::HIGHEST_HOLD)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      ascent = ContestParticipantAscent.new(hold_number: 10, hold_number_plus: true)
      assert_equal 10.5, ranker.scores(ascent)[:value]
      assert_equal [10, 1], ranker.scores(ascent)[:details]
    end

    test 'scores for POINT_RELATIVE_TO_HIGHEST_HOLD' do
      @step.update_column(:ranking_type, Constant::POINT_RELATIVE_TO_HIGHEST_HOLD)
      @route.update_columns(fixed_points: 1000, number_of_holds: 20)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      ascent = ContestParticipantAscent.new(contest_route: @route, hold_number: 10)
      assert_equal 500, ranker.scores(ascent)[:value]
    end

    test 'scores for BEST_TIMES' do
      @step.update_column(:ranking_type, Constant::BEST_TIMES)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      
      time = Time.zone.now.change(min: 1, sec: 10, usec: 500000)
      ascent = ContestParticipantAscent.new(ascent_time: time)
      
      score = ranker.scores(ascent)
      assert_equal time.seconds_since_midnight * -1, score[:value]
      assert_match /1m 10s 500ms/, score[:details].first
    end

    test 'participant_scores aggregates correctly' do
      @step.update_column(:ranking_type, Constant::FIXED_POINTS)
      @route.update_column(:fixed_points, 100)
      route2 = contest_routes(:route_2)
      route2.update_column(:fixed_points, 200)
      
      ContestParticipantAscent.delete_all
      ContestParticipantAscent.create!(contest_participant: @participant, contest_route: @route, realised: true)
      ContestParticipantAscent.create!(contest_participant: @participant, contest_route: route2, realised: true)
      
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      p_scores = ranker.participant_scores(@participant.id)
      
      assert_equal 300, p_scores[:value]
      assert_equal [300], p_scores[:details]
      assert_equal %w[pts], p_scores[:units]
    end

    test 'participant_scores with ascents_limit' do
      @step.update_columns(ranking_type: Constant::FIXED_POINTS, ascents_limit: 1)
      @route.update_column(:fixed_points, 100)
      route2 = contest_routes(:route_2)
      route2.update_column(:fixed_points, 200)
      
      ContestParticipantAscent.delete_all
      ContestParticipantAscent.create!(contest_participant: @participant, contest_route: @route, realised: true)
      ContestParticipantAscent.create!(contest_participant: @participant, contest_route: route2, realised: true)
      
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      p_scores = ranker.participant_scores(@participant.id)
      
      assert_equal 200, p_scores[:value]
    end
  end
end
