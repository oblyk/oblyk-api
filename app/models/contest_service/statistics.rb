# frozen_string_literal: true

module ContestService
  class Statistics

    def initialize(contest, category_id: nil, genre: nil, exclude_without_ascents: false)
      genre = nil if genre == 'unisex'
      @contest = contest
      @genre = genre
      @exclude_without_ascents = exclude_without_ascents
      @category = contest.contest_categories.find(category_id) if category_id.present?
      @participants = nil
      @ascents = nil
    end

    def participants_figure
      build_participants

      number_of_participants = @participants.count
      with_ascents = @participants.with_ascents.count
      without_ascents = number_of_participants - with_ascents
      {
        total: number_of_participants,
        female: @participants.where(genre: :female).count,
        male: @participants.where(genre: :male).count,
        without_ascents: without_ascents,
        with_ascents: with_ascents,
        participation: ((number_of_participants - without_ascents).to_d / number_of_participants.to_d * 100.0).round(1)
      }
    end

    def by_ages
      build_participants

      participants = @participants.select('COUNT(*) AS count, TIMESTAMPDIFF(YEAR, contest_participants.date_of_birth, CURDATE()) AS age')
                                  .group('2')
                                  .reorder('2')
      return false if participants.blank?

      participants = participants.map { |participant| { age: participant[:age], count: participant[:count] } }

      number_of_participants = participants.sum { |participant| participant[:count] }
      min_age = participants.first[:age]
      max_age = participants.last[:age]
      ages = participants.map { |participant| participant[:age] }
      (min_age..max_age).each do |age_rank|
        participants << { age: age_rank, count: 0 } if ages.exclude?(age_rank)
      end

      {
        ages: participants.sort_by! { |participant| participant[:age] },
        average: participants.sum { |participant| participant[:count] * participant[:age] } / number_of_participants.to_d
      }
    end

    def ascents_by_steps
      build_ascents
      contest_structures = []

      stages = @contest.contest_stages
                       .includes(
                         contest_stage_steps: {
                           contest_route_groups: [
                             :contest_routes,
                             { contest_route_group_categories: :contest_category }
                           ]
                         }
                       )
                       .order(:stage_order)

      stages.each do |stage|
        stage_hash = {
          name: stage.name,
          climbing_type: stage.climbing_type,
          steps: []
        }
        stage.contest_stage_steps.order(:step_order).each do |step|
          participants_step = ContestParticipantStep.joins(:contest_participant).where(contest_stage_step_id: step.id)
          participants_step = participants_step.where(contest_participants: { genre: @genre }) if @genre.present?
          participants_step = participants_step.where(contest_participants: { contest_category_id: @category.id }) if @category.present?
          participants_step = participants_step.where('EXISTS(SELECT * FROM contest_participant_ascents WHERE contest_participants.id = contest_participant_ascents.contest_participant_id)') if @exclude_without_ascents
          step_hash = {
            name: step.name,
            ranking_type: step.ranking_type,
            groups: [],
            number_of_participants: participants_step.count
          }
          step.contest_route_groups.each do |route_group|
            group_categories = route_group.contest_route_group_categories.map(&:contest_category)
            number_of_participants = participants_step.where(contest_participants: { contest_category_id: group_categories.pluck(:id) }).count
            group_hash = {
              genre_type: route_group.genre_type,
              categories: group_categories.pluck(:name),
              number_of_participants: number_of_participants,
              routes: []
            }
            route_group.contest_routes.includes(picture_attachment: :blob).each do |route|
              route_hash = {
                id: route.id,
                number: route.number,
                name: route.name,
                attachments: {
                  gym_route_thumbnail: route.attachment_object(route.gym_route&.thumbnail, 'GymRoute_thumbnail'),
                  picture: route.attachment_object(route.picture)
                }
              }
              ascents = @ascents.select { |ascent| ascent.contest_route_id == route.id }

              # For each type of ranking system get stats
              if [Constant::DIVISION, Constant::FIXED_POINTS].include? step.ranking_type
                top = 0.0
                ascents.each do |ascent|
                  top += 1 if ascent.realised
                end
                route_hash[:top] = top
                route_hash[:top_ratio] = top.zero? ? 0 : (top.to_f / number_of_participants * 100).round(1)
              end

              if [Constant::DIVISION_AND_ZONE, Constant::ZONE_AND_TOP_REALISED].include? step.ranking_type
                top = 0.0
                zone = 0.0
                ascents.each do |ascent|
                  top += 1 if ascent.realised || ascent.top_attempt&.positive?
                  zone += 1 if (ascent.zone_1_attempt&.positive? || ascent.realised || ascent.top_attempt&.positive?) && route.additional_zone
                end
                route_hash[:top] = top
                route_hash[:zone] = route.additional_zone ? zone : nil
                route_hash[:top_ratio] = top.zero? ? 0 : (top / number_of_participants * 100).round(1)
                route_hash[:zone_ratio] = if !route.additional_zone
                                            nil
                                          elsif zone.zero?
                                            0
                                          else
                                            (zone / number_of_participants * 100.0).round(1)
                                          end
                route_hash[:top_vs_zone] = if zone.zero? || !route.additional_zone
                                             nil
                                           elsif top.zero?
                                             0
                                           else
                                             (top / zone * 100).round(1)
                                           end
              end

              if [Constant::ZONE_AND_TOP_REALISED].include? step.ranking_type
                top = 0.0
                zone = 0.0
                ascents.each do |ascent|
                  top += 1 if ascent.top_attempt == 1
                  zone += 1 if ascent.zone_1_attempt || ascent.top_attempt == 1
                end
                route_hash[:top] = top
                route_hash[:zone] = zone
                route_hash[:top_ratio] = top.zero? ? 0 : (top / number_of_participants * 100).round(1)
                route_hash[:zone_ratio] = zone.zero? ? 0 : (zone / number_of_participants * 100.0).round(1)
                route_hash[:top_vs_zone] = if zone.zero?
                                             nil
                                           elsif top.zero?
                                             0
                                           else
                                             (top / zone * 100).round(1)
                                           end
              end

              if [Constant::ATTEMPTS_TO_ONE_ZONE_AND_TOP].include? step.ranking_type
                top = 0.0
                zone = 0.0
                top_attempt = 0.0
                zone_attempt = 0.0
                ascents.each do |ascent|
                  top += 1 if ascent.top_attempt&.positive?
                  zone += 1 if ascent.zone_1_attempt&.positive? || ascent.top_attempt&.positive?
                  top_attempt += ascent.top_attempt if ascent.top_attempt&.positive?
                  zone_attempt += ascent.zone_1_attempt if ascent.zone_1_attempt&.positive?
                end
                route_hash[:top] = top
                route_hash[:top_attempt] = top_attempt
                route_hash[:top_attempt_average] = top.zero? ? 0 : (top_attempt / top).round(2)
                route_hash[:top_ratio] = top.zero? ? 0 : (top / number_of_participants * 100).round(1)
                route_hash[:zone] = zone
                route_hash[:zone_attempt] = zone_attempt
                route_hash[:zone_attempt_average] = zone.zero? ? 0 : (zone_attempt / zone).round(2)
                route_hash[:zone_ratio] = zone.zero? ? 0 : (zone / number_of_participants * 100).round(1)
              end

              if [Constant::DIVISION_AND_ATTEMPT, Constant::ATTEMPTS_TO_TOP].include? step.ranking_type
                top = 0.0
                top_attempt = 0.0
                top_by_attempt = Hash.new { |h, k| h[k] = 0 }
                ascents.each do |ascent|
                  if step.ranking_type == Constant::DIVISION_AND_ATTEMPT
                    top += 1 if ascent.realised
                    next unless ascent.realised
                  else
                    top += 1 if ascent.top_attempt >= 1
                    next unless ascent.top_attempt
                  end

                  top_attempt += ascent.top_attempt
                  top_by_attempt[ascent.top_attempt] += 1
                end
                top_by_attempt_color = []
                route_hash[:top] = top
                route_hash[:top_attempt] = top_attempt
                number_of_tentatives = top_by_attempt.max_by(&:first)&.first
                if number_of_tentatives.present?
                  (1..number_of_tentatives).each do |index|
                    top_by_attempt[index] ||= 0
                    top_by_attempt_color << '#7b1fa2'
                  end
                end
                top_by_attempt = top_by_attempt.sort.to_h
                route_hash[:top_by_attempt_colors] = top_by_attempt_color
                route_hash[:top_by_attempt] = top_by_attempt.map(&:last)
                route_hash[:top_ratio] = top.zero? ? 0 : (top / number_of_participants * 100).round(1)
                route_hash[:attempt_average] = top.zero? ? 0 : (top_attempt / top).round(2)
              end

              if [Constant::HIGHEST_HOLD, Constant::POINT_RELATIVE_TO_HIGHEST_HOLD].include? step.ranking_type
                route_number_of_holds = route.number_of_holds || 0
                top = 0
                max_hold = nil
                min_hold = nil
                max_holds = Hash.new { |h, k| h[k] = 0 }
                colors = []
                (0..route_number_of_holds).each do |index|
                  max_holds[index] = 0
                  colors << '#7b1fa2'
                end
                holds = []
                ascents.each do |ascent|
                  next if ascent.hold_number.blank?

                  top += 1 if ascent.hold_number >= route_number_of_holds
                  max_hold = ascent.hold_number if max_hold.blank? || ascent.hold_number > max_hold
                  min_hold = ascent.hold_number if min_hold.blank? || ascent.hold_number < min_hold
                  holds << ascent.hold_number || 0
                  (0..ascent.hold_number || 0).each do |index|
                    max_holds[index] += 1
                  end
                end
                route_hash[:top] = top
                route_hash[:max_hold] = max_hold
                route_hash[:min_hold] = min_hold
                route_hash[:holds_chart] = max_holds.map(&:last)
                route_hash[:colors_chart] = colors
                route_hash[:average_hold] = holds.size.zero? ? 0 : (holds.sum.to_f / holds.size).round(1)
                route_hash[:top_ratio] = top.zero? ? 0 : (top.to_f / number_of_participants * 100).round(1)
              end

              if [Constant::BEST_TIMES].include? step.ranking_type
                best_time = nil
                worst_time = nil
                times = []
                colors = []
                ascents.each do |ascent|
                  next if ascent.ascent_time.blank? || ascent.ascent_time.to_i <= 946_684_800

                  best_time = ascent.ascent_time if best_time.blank? || ascent.ascent_time < best_time
                  worst_time = ascent.ascent_time if worst_time.blank? || ascent.ascent_time > worst_time
                  times << { y: ascent.ascent_time, x: 0 }
                end
                times.each do |_time|
                  colors << '#7b1fa2'
                end
                route_hash[:best_time] = best_time
                route_hash[:worst_time] = worst_time
                times.sort_by! { |time| time[:y] }.reverse!
                times.each_with_index do |time, index|
                  time[:x] = index + 1
                end
                route_hash[:times_chart] = times
                route_hash[:colors_chart] = colors
                route_hash[:average_time] = times.size.zero? ? 0 : Time.zone.at((times.sum { |time| time[:y]&.to_i }).to_f / times.size).round(0)
              end

              group_hash[:routes] << route_hash
            end
            step_hash[:groups] << group_hash
          end
          stage_hash[:steps] << step_hash
        end
        contest_structures << stage_hash
      end

      contest_structures
    end

    private

    def build_participants
      return @participants if @participants.present?

      participants = @contest.contest_participants
      participants = participants.where(genre: @genre) if @genre.present?
      participants = participants.where(contest_category_id: @category.id) if @category.present?
      participants = participants.with_ascents if @exclude_without_ascents
      @participants = participants
    end

    def build_ascents
      return @ascents if @ascents.present?

      ascents = ContestParticipantAscent.joins(contest_participant: :contest_category).where(contest_categories: { contest_id: @contest.id })
      ascents = ascents.where(contest_participants: { genre: @genre }) if @genre.present?
      ascents = ascents.where(contest_participants: { contest_category_id: @category.id }) if @category.present?
      ascents = ascents.where('EXISTS(SELECT * FROM contest_participant_ascents WHERE contest_participants.id = contest_participant_ascents.contest_participant_id)') if @exclude_without_ascents
      @ascents = ascents.to_a
    end

    def time_format(time)
      if time.blank? # || time.zero?
        '-'
      else
        sec = time.sec
        min = time.min
        subsec = (time.subsec.to_f * 1000).to_i
        "#{"#{min}m " if min != 0}#{sec}s #{subsec}ms"
      end
    end
  end
end
