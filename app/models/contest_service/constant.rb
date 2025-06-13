# frozen_string_literal: true

module ContestService
  class Constant
    DIVISION = 'division'
    DIVISION_AND_ZONE = 'division_and_zone'
    DIVISION_AND_ATTEMPT = 'division_and_attempt'
    ATTEMPTS_TO_TOP = 'attempts_to_top'
    ZONE_AND_TOP_REALISED = 'zone_and_top_realised'
    ATTEMPTS_TO_ONE_ZONE_AND_TOP = 'attempts_to_one_zone_and_top'
    ATTEMPTS_TO_TWO_ZONES_AND_TOP = 'attempts_to_two_zones_and_top'
    FIXED_POINTS = 'fixed_points'
    HIGHEST_HOLD = 'highest_hold'
    BEST_TIMES = 'best_times'

    RANKING_TYPE_LIST = [
      DIVISION,
      DIVISION_AND_ZONE,
      DIVISION_AND_ATTEMPT,
      ATTEMPTS_TO_TOP,
      ZONE_AND_TOP_REALISED,
      ATTEMPTS_TO_ONE_ZONE_AND_TOP,
      ATTEMPTS_TO_TWO_ZONES_AND_TOP,
      HIGHEST_HOLD,
      FIXED_POINTS,
      BEST_TIMES
    ].freeze

    RANKING_UNITS = {
      DIVISION => %w[pts],
      DIVISION_AND_ZONE => %w[pts zone(s)],
      DIVISION_AND_ATTEMPT => %w[pts essais],
      ATTEMPTS_TO_TOP => %w[pts],
      FIXED_POINTS => %w[pts],
      ZONE_AND_TOP_REALISED => %w[top zone(s)],
      ATTEMPTS_TO_ONE_ZONE_AND_TOP => 'zone_and_top_blocks',
      HIGHEST_HOLD => %w[prise(s) +],
      BEST_TIMES => %w[]
    }.freeze

    COMBINED_RANKING_ADDITION = 'addition'
    COMBINED_RANKING_MULTIPLICATION = 'multiplication'
    COMBINED_RANKING_DECREMENT_POINTS = 'decrement_points'
    COMBINED_RANKING_TYPE_LIST = [
      COMBINED_RANKING_ADDITION,
      COMBINED_RANKING_MULTIPLICATION,
      COMBINED_RANKING_DECREMENT_POINTS
    ].freeze

    COMBINED_RANKING_POINT_MATRIX = [
      100, 80, 65, 55, 51, 47, 43, 40,
      37, 34, 31, 28, 26, 24, 22, 20,
      18, 16, 14, 12, 10, 9, 8, 7, 6,
      5, 4, 3, 2, 1
    ].freeze
  end
end
