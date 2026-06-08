# frozen_string_literal: true

require 'test_helper'

module ContestService
  class RankerTest < ActiveSupport::TestCase
    setup do
      @step = contest_stage_steps(:step_1_stage_1)
      @category = contest_categories(:category_senior)
      @genre = 'male'
      @ranker = ContestService::Ranker.new(@step, @category, @genre)
    end

    test 'initialize sets correct attributes' do
      assert_equal @step, @ranker.step
      assert_equal @category, @ranker.category
      assert_equal @genre, @ranker.genre
      assert_not_nil @ranker.ascents
    end

    test 'scores returns division point' do
      ascent = contest_participant_ascents(:ascent_1)
      score = @ranker.scores(ascent)
      assert_equal 1000, score[:value]
      assert_equal [1000], score[:details]
    end

    test 'scores returns no score for blank ascent' do
      score = @ranker.scores(nil)
      assert_nil score[:value]
      assert_equal ['NR'], score[:details]
    end

    test 'participant_scores returns global score for participant' do
      participant = contest_participants(:participant_1)
      p_scores = @ranker.participant_scores(participant.id)

      assert_equal 1000, p_scores[:value]
      assert_equal [1000], p_scores[:details]
      assert_equal %w[pts], p_scores[:units]
    end

    test 'scores for FIXED_POINTS ranking type' do
      @step.update_column(:ranking_type, Constant::FIXED_POINTS)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      ascent = contest_participant_ascents(:ascent_1)
      ascent.contest_route.update_column(:fixed_points, 50)

      score = ranker.scores(ascent)
      assert_equal 50, score[:value]
      assert_equal [50], score[:details]
    end

    test 'scores for ZONE_AND_TOP_REALISED ranking type' do
      @step.update_column(:ranking_type, Constant::ZONE_AND_TOP_REALISED)
      ranker = ContestService::Ranker.new(@step, @category, @genre)
      ascent = contest_participant_ascents(:ascent_2)

      score = ranker.scores(ascent)
      assert_equal 1.001, score[:value]
      assert_equal [true, true], score[:details]
    end
  end
end
