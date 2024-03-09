# frozen_string_literal: true

class ContestRanking
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
    100,
    80,
    65,
    55,
    51,
    47,
    43,
    40,
    37,
    34,
    31,
    28,
    26,
    24,
    22,
    20,
    18,
    16,
    14,
    12,
    10,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    2,
    1
  ].freeze

  attr_accessor :ascents, :step, :category, :genre, :score_by_routes

  def initialize(step, category, genre)
    self.step = step
    self.category = category
    self.genre = genre

    self.ascents = ContestParticipantAscent.joins(:contest_participant, contest_route: :contest_route_group)
                                           .where(contest_participants: { contest_category_id: category.id })
                                           .where(contest_routes: { disabled_at: nil })
                                           .where(contest_route_groups: { contest_stage_step_id: step.id })

    self.ascents = ascents.where(contest_participants: { genre: genre }) unless category.unisex
    self.ascents = ascents.where(realised: true) if [DIVISION, DIVISION_AND_ATTEMPT, FIXED_POINTS].include?(step.ranking_type)
    self.score_by_routes = {}
  end

  def scores(ascent_id)
    current_ascent = ascents.find { |ascent| ascent.id == ascent_id }
    no_score = { value: nil, details: ['NR'] }

    return no_score if current_ascent.blank?

    case step.ranking_type
    when DIVISION
      score_by_routes[current_ascent.contest_route_id] ||= (1000 / ascents.count { |ascent| ascent.contest_route_id == current_ascent.contest_route_id })
      point = score_by_routes[current_ascent.contest_route_id]
      {
        value: point,
        details: [point]
      }
    when DIVISION_AND_ZONE
      point = if current_ascent.top_attempt&.positive?
                score_by_routes[current_ascent.contest_route_id] ||= (1000 / ascents.count { |ascent| ascent.contest_route_id == current_ascent.contest_route_id && ascent.top_attempt&.positive? })
              else
                0
              end
      zone = !current_ascent.top_attempt&.positive? && current_ascent.zone_1_attempt&.positive? || false
      point_with_zone = point
      point_with_zone += 0.5 if zone
      {
        value: point_with_zone,
        details: [point, zone]
      }
    when DIVISION_AND_ATTEMPT
      point = if current_ascent.realised?
                score_by_routes[current_ascent.contest_route_id] ||= (1000 / ascents.count { |ascent| ascent.contest_route_id == current_ascent.contest_route_id && ascent.realised? })
              else
                0
              end
      value = point
      attempt = 0
      if current_ascent.realised?
        attempt = current_ascent.top_attempt&.positive? ? current_ascent.top_attempt : 1
        value -= attempt / 1000.0
      end
      {
        value: value,
        details: [point, attempt]
      }
    when FIXED_POINTS
      point = current_ascent.contest_route.fixed_points || 0
      {
        value: point,
        details: [point]
      }
    when ATTEMPTS_TO_TOP
      point = 10 - (current_ascent.top_attempt - 1)
      {
        value: point,
        details: [point]
      }
    when ZONE_AND_TOP_REALISED
      top = current_ascent.top_attempt&.positive? || false
      zone = current_ascent.zone_1_attempt&.positive? || false
      value = 0
      value = 1.001 if top
      value = 0.001 if !top && zone
      {
        value: value,
        details: [top, zone]
      }
    when ATTEMPTS_TO_ONE_ZONE_AND_TOP
      top = current_ascent.top_attempt || 0
      zone = current_ascent.zone_1_attempt || 0
      value = 0
      value = 1000.0 if top.positive?
      value -= top / 10.0
      value += 1.0 if zone.positive?
      value -= zone / 1000.0
      {
        value: value,
        details: [top, zone]
      }
    when HIGHEST_HOLD
      point = current_ascent.hold_number
      point += 0.5 if current_ascent.hold_number_plus
      plus = current_ascent.hold_number_plus ? 1 : 0
      {
        value: point,
        details: [current_ascent.hold_number, plus]
      }
    when BEST_TIMES
      second = current_ascent.ascent_time&.seconds_since_midnight
      detail = if second.blank? || second.zero?
                 '-'
               else
                 sec = current_ascent.ascent_time.sec
                 min = current_ascent.ascent_time.min
                 subsec = (current_ascent.ascent_time.subsec.to_f * 1000).to_i
                 "#{"#{min}m " if min != 0}#{sec}s #{subsec}ms"
               end
      {
        value: current_ascent.ascent_time ? current_ascent.ascent_time.seconds_since_midnight * -1 : nil,
        details: [detail]
      }
    else
      no_score
    end
  end

  def participant_scores(participant_id)
    value = nil
    details = nil

    ascents.each do |ascent|
      next if ascent.contest_participant_id != participant_id

      ascent_scores = scores(ascent.id)
      ascent_value = ascent_scores[:value]

      next unless ascent_scores[:value]

      if step.ranking_type == BEST_TIMES
        value ||= 60 * 60 * -1
      else
        value ||= 0
        value += ascent_value
      end

      if [DIVISION, ATTEMPTS_TO_TOP, FIXED_POINTS].include? step.ranking_type
        details ||= [0]
        details[0] += ascent_value if ascent_value.present?
      elsif [DIVISION_AND_ZONE].include? step.ranking_type
        details ||= [0, 0]
        if ascent_value.present?
          details[0] += ascent_scores[:details].first
          details[1] += 1 if ascent_scores[:details].second
        end
      elsif [DIVISION_AND_ATTEMPT].include? step.ranking_type
        details ||= [0, 0]
        if ascent_value.present?
          details[0] += ascent_scores[:details].first
          details[1] += ascent_scores[:details].second
        end
      elsif [ATTEMPTS_TO_ONE_ZONE_AND_TOP].include? step.ranking_type
        details ||= []
        details << { top: ascent_scores[:details].first, zone: ascent_scores[:details].second }
      elsif [ZONE_AND_TOP_REALISED].include? step.ranking_type
        details ||= [0, 0]
        if ascent_value.present?
          details[0] += 1 if ascent_scores[:details].first
          details[1] += 1 if ascent_scores[:details].second
        end
      elsif [HIGHEST_HOLD].include? step.ranking_type
        details ||= [0, 0]
        if ascent_value.present?
          details[0] += ascent_scores[:details].first
          details[1] += ascent_scores[:details].second
        end
      elsif [BEST_TIMES].include? step.ranking_type
        value = ascent_value if ascent_value.present? && ascent_value != 0 && value < ascent_value
        details ||= []
        details << ascent_scores[:details].first
      end
    end
    { value: value, details: details, units: RANKING_UNITS[step.ranking_type] }
  end
end
