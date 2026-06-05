# frozen_string_literal: true

require 'test_helper'

module Statistics
  class GymStatisticTest < ActiveSupport::TestCase
    setup do
      @gym = gyms(:my_gym)
      @date = Date.current
      @statistic = Statistics::GymStatistic.new(@gym, @date)
    end

    test 'initializes correctly' do
      assert_equal @gym, @statistic.gym
      assert_equal @date, @statistic.date
      assert_equal [], @statistic.space_ids
      assert_equal [], @statistic.opener_ids
    end

    test 'figures returns correct data' do
      # On s'assure qu'il y a des voies
      route = gym_routes(:gym_route_one)
      route.update(opened_at: @date - 10.days)
      
      figures = @statistic.figures
      
      assert figures.key?(:route_count)
      assert figures.key?(:ascent_count)
      assert figures.key?(:opening)
      assert figures.key?(:grade)
      assert_equal @gym.gym_routes.count, figures[:route_count]
    end

    test 'routes_by_grades returns chart data' do
      data = @statistic.routes_by_grades
      
      assert data.key?(:datasets)
      assert data.key?(:labels)
      assert_kind_of Array, data[:datasets]
      assert_kind_of Array, data[:labels]
    end

    test 'routes_by_levels returns chart data' do
      # Nécessite des gym_levels configurés dans les fixtures
      charts = @statistic.routes_by_levels
      
      assert_kind_of Array, charts
      if charts.any?
        chart = charts.first
        assert chart.key?(:type)
        assert chart.key?(:climbing_type)
        assert chart.key?(:chart)
      end
    end

    test 'notes returns correct distribution' do
      route = gym_routes(:gym_route_one)
      # Création d'une ascension avec note
      ascent = AscentGymRoute.new(
        gym_route: route,
        gym: @gym,
        user: users(:normal_user),
        ascent_status: 'repetition',
        released_at: @date,
        note: 4,
        climbing_type: 'bouldering'
      )
      ascent.save(validate: false)
      
      notes = @statistic.notes
      assert_equal 1, notes[4]
    end

    test 'like_figures returns correct data' do
      route = gym_routes(:gym_route_one)
      route.update(likes_count: 5)
      
      likes = @statistic.like_figures
      assert_equal 5, likes[:likes_count]
      assert_equal 1, likes[:liked_routes]
    end

    test 'difficulty_appreciation returns correct data' do
      route = gym_routes(:gym_route_one)
      route.update(votes: { 
        difficulty_appreciations: { 
          'easy_for_the_grade' => { 'count' => 2 },
          'this_grade_is_accurate' => { 'count' => 5 },
          'sandbagged' => { 'count' => 1 }
        } 
      })
      
      appreciation = @statistic.difficulty_appreciation
      assert_equal 2, appreciation[:easy_for_the_grade]
      assert_equal 5, appreciation[:this_grade_is_accurate]
      assert_equal 1, appreciation[:sandbagged]
    end

    test 'opening_frequencies returns chart data' do
      data = @statistic.opening_frequencies
      
      assert data.key?(:datasets)
      assert data.key?(:labels)
    end
    
    test 'filtering by space_ids' do
      space = gym_spaces(:my_gym_boulder_space)
      stat_with_filter = Statistics::GymStatistic.new(@gym, @date, space_ids: [space.id])
      
      figures = stat_with_filter.figures
      expected_count = @gym.gym_routes.joins(gym_sector: :gym_space).where(gym_spaces: { id: space.id }).count
      assert_equal expected_count, figures[:route_count]
    end

    test 'filtering by opener_ids' do
      opener = gym_openers(:opener_one)
      route = gym_routes(:gym_route_one)
      # On lie un ouvreur à la voie
      GymRouteOpener.create!(gym_route: route, gym_opener: opener)
      
      stat_with_filter = Statistics::GymStatistic.new(@gym, @date, opener_ids: [opener.id])
      figures = stat_with_filter.figures
      
      assert_equal 1, figures[:route_count]
    end
  end
end
