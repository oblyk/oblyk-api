# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Indoor
    class FigureTest < ActiveSupport::TestCase
      setup do
        @user = users(:normal_user)
        @ascent = ascent_gym_routes(:gym_ascent_one)
        # S'assurer que l'ascent est bien comptée
        @ascent.update_columns(
          released_at: Date.current,
          quantity: 1,
          height: 10,
          max_grade_value: 32
        )
      end

      test 'figures returns expected statistics' do
        figure = Figure.new(@user)
        stats = figure.figures

        assert_equal 1, stats[:ascents]
        assert_equal 10.0, stats[:meters]
        assert_equal 32, stats[:max_grade_value]
        assert_kind_of Hash, stats[:last_28_days]
        assert_equal 1, stats[:last_28_days][:ascents]
      end

      test 'geographic stats' do
        figure = Figure.new(@user)
        stats = figure.figures

        # my_gym est associé à @ascent dans les fixtures
        assert_equal 1, stats[:gyms]
        assert_equal 1, stats[:countries]
        assert_equal 1, stats[:regions]
      end

      test 'climbing sessions stats' do
        # On crée une session pour l'utilisateur avec une ascension indoor
        session = ClimbingSession.create!(
          user: @user,
          session_date: Date.current
        )
        @ascent.update_column(:climbing_session_id, session.id)

        figure = Figure.new(@user)
        stats = figure.figures

        assert_equal 1, stats[:last_28_days][:sessions]
      end
    end
  end
end
