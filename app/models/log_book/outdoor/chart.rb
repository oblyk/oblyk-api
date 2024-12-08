# frozen_string_literal: true

module LogBook
  module Outdoor
    class Chart
      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def uniq_ascent_crag_routes(only_lead_climbs=false)
        if only_lead_climbs
          @user.ascent_crag_routes.made.lead.uniq(&:crag_route_id)
        else
          @user.ascent_crag_routes.made.uniq(&:crag_route_id)
        end
      end

      def climb_type(only_lead_climbs=false)
        sport_climbing = 0
        bouldering = 0
        multi_pitch = 0
        trad_climbing = 0
        aid_climbing = 0
        deep_water = 0
        via_ferrata = 0

        uniq_ascent_crag_routes(only_lead_climbs).each do |ascent|
          sport_climbing += 1 if ascent.climbing_type == 'sport_climbing'
          bouldering += 1 if ascent.climbing_type == 'bouldering'
          multi_pitch += 1 if ascent.climbing_type == 'multi_pitch'
          trad_climbing += 1 if ascent.climbing_type == 'trad_climbing'
          aid_climbing += 1 if ascent.climbing_type == 'aid_climbing'
          deep_water += 1 if ascent.climbing_type == 'deep_water'
          via_ferrata += 1 if ascent.climbing_type == 'via_ferrata'
        end

        {
          datasets: [
            {
              data: [
                sport_climbing,
                bouldering,
                multi_pitch,
                trad_climbing,
                aid_climbing,
                deep_water,
                via_ferrata
              ],
              backgroundColor: [
                Climb::COLOR[Climb::SPORT_CLIMBING],
                Climb::COLOR[Climb::BOULDERING],
                Climb::COLOR[Climb::MULTI_PITCH],
                Climb::COLOR[Climb::TRAD_CLIMBING],
                Climb::COLOR[Climb::AID_CLIMBING],
                Climb::COLOR[Climb::DEEP_WATER],
                Climb::COLOR[Climb::VIA_FERRATA]
              ],
              label: 'climb_type'
            }
          ],
          labels: %w[sport_climbing bouldering multi_pitch trad_climbing aid_climbing deep_water via_ferrata]
        }
      end

      def grade(only_lead_climbs=false)
        grades = {}
        54.times do |grade_value|
          next unless grade_value.even?

          grades[grade_value + 1] = { count: 0 }
        end

        uniq_ascent_crag_routes(only_lead_climbs).each do |ascent|
          next if ascent.min_grade_value.blank? || ascent.min_grade_value.zero?

          grade_value = ascent.sections.map { |section| section['grade_value'] }.max
          grade_value -= 1 if grade_value.even?

          grades[grade_value][:count] += 1
        end

        {
          datasets: [
            {
              data: grades.map { |grade| grade[1][:count] },
              backgroundColor: grades.map { |grade| Grade.value_color(grade[0] - 1) },
              label: 'number'
            }
          ],
          labels: grades.map { |grade| grade[0] }
        }
      end

      def years(only_lead_climbs=false)
            if uniq_ascent_crag_routes(only_lead_climbs).count.zero?
          return {
            datasets: [{ data: [] }],
            labels: []
          }
        end

        min_year = uniq_ascent_crag_routes(only_lead_climbs).minimum(:released_at).year
        max_year = uniq_ascent_crag_routes(only_lead_climbs).maximum(:released_at).year
        years = {}

        (min_year..max_year).each do |year|
          years[year] = { count: 0 }
        end

        uniq_ascent_crag_routes(only_lead_climbs).order(:released_at).each do |ascent|
          next if ascent.released_at.blank?

          years[ascent.released_at.year][:count] += 1
        end

        {
          datasets: [
            {
              data: years.map { |year| year[1][:count] },
              backgroundColor: '#1565c0',
              label: 'number'
            }
          ],
          labels: years.map { |year| year[0] }
        }
      end

      def months(only_lead_climbs=false)

        if uniq_ascent_crag_routes(only_lead_climbs).count.zero?
          return {
            datasets: [{ data: [] }],
            labels: []
          }
        end

        min_date = uniq_ascent_crag_routes(only_lead_climbs).minimum(:released_at)
        max_date = uniq_ascent_crag_routes(only_lead_climbs).maximum(:released_at)
        dates = {}

        (min_date..max_date).each do |date|
          dates[date.strftime('%Y-%m')] ||= { count: 0 }
        end

        uniq_ascent_crag_routes(only_lead_climbs).order(:released_at).each do |ascent|
          next if ascent.released_at.blank?

          dates[ascent.released_at.strftime('%Y-%m')][:count] += 1
        end

        {
          datasets: [
            {
              data: dates.map { |date| date[1][:count] },
              backgroundColor: '#1565c0',
              label: 'number'
            }
          ],
          labels: dates.map { |date| date[0] }
        }
      end

      def evolution_by_year(only_lead_climbs=false)
        if uniq_ascent_crag_routes(only_lead_climbs).count.zero?
          return {
            datasets: [{ data: [] }],
            labels: []
          }
        end

        min_year = uniq_ascent_crag_routes(only_lead_climbs).minimum(:released_at).year
        max_year = uniq_ascent_crag_routes(only_lead_climbs).maximum(:released_at).year
        years = {}

        (min_year..max_year).each do |year|
          years[year] = {
            sport_climbing: 0,
            bouldering: 0,
            multi_pitch: 0,
            trad_climbing: 0,
            aid_climbing: 0,
            deep_water: 0,
            via_ferrata: 0
          }
        end

        uniq_ascent_crag_routes(only_lead_climbs).each do |ascent|
          next if ascent.max_grade_value.blank?

          grade_value = years[ascent.released_at.year][ascent.climbing_type.to_sym]
          next if grade_value > ascent.max_grade_value

          years[ascent.released_at.year][ascent.climbing_type.to_sym] = ascent.max_grade_value
        end

        datasets = []

        if years.map { |year| year[1][:sport_climbing] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:sport_climbing] },
            borderColor: Climb::COLOR[Climb::SPORT_CLIMBING],
            fill: false,
            label: 'sport_climbing'
          }
        end

        if years.map { |year| year[1][:bouldering] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:bouldering] },
            borderColor: Climb::COLOR[Climb::BOULDERING],
            fill: false,
            label: 'bouldering'
          }
        end

        if years.map { |year| year[1][:multi_pitch] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:multi_pitch] },
            borderColor: Climb::COLOR[Climb::MULTI_PITCH],
            fill: false,
            label: 'multi_pitch'
          }
        end

        if years.map { |year| year[1][:trad_climbing] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:trad_climbing] },
            borderColor: Climb::COLOR[Climb::TRAD_CLIMBING],
            fill: false,
            label: 'trad_climbing'
          }
        end

        if years.map { |year| year[1][:aid_climbing] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:aid_climbing] },
            borderColor: Climb::COLOR[Climb::AID_CLIMBING],
            fill: false,
            label: 'aid_climbing'
          }
        end

        if years.map { |year| year[1][:deep_water] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:deep_water] },
            borderColor: Climb::COLOR[Climb::DEEP_WATER],
            fill: false,
            label: 'deep_water'
          }
        end

        if years.map { |year| year[1][:via_ferrata] }.sum.positive?
          datasets << {
            data: years.map { |year| year[1][:via_ferrata] },
            borderColor: Climb::COLOR[Climb::VIA_FERRATA],
            fill: false,
            label: 'via_ferrata'
          }
        end

        {
          datasets: datasets,
          labels: years.map { |year| year[0] }
        }
      end
    end
  end
end
